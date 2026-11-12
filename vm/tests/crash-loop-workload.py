#!/usr/bin/env python3
"""Write load and ledger check for vm/tests/crash-loop.sh (see its header).

  crash-loop-workload.py run    DIR LEDGER [MAXBYTES]   # runs until killed
  crash-loop-workload.py verify DIR LEDGER              # exit 0 = consistent

`run` creates, overwrites and deletes files under DIR. After each operation it
calls fcntl(F_FULLFSYNC) on the file and on DIR (what Time Machine's APFS
barrier boils down to) and only then appends "done" to LEDGER on the local
disk. `verify` replays LEDGER: every file whose operation completed must have
exactly the recorded SHA-256 (or be absent after a completed delete); the one
operation that was in flight when the machine was killed may have either state.
"""
import fcntl
import hashlib
import json
import os
import random
import signal
import sys


def fullfsync(fd):
    fcntl.fcntl(fd, fcntl.F_FULLFSYNC)


def sha_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(1 << 20):
            h.update(chunk)
    return h.hexdigest()


def write_file(path, size, mode):
    h = hashlib.sha256()
    chunks = []
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | (os.O_TRUNC if mode == "w" else 0), 0o644)
    try:
        left = size
        while left > 0:
            n = min(left, 1 << 20)
            chunk = os.urandom(n)
            h.update(chunk)
            chunks.append(hashlib.sha1(chunk).hexdigest()[:8])
            os.write(fd, chunk)
            left -= n
        fullfsync(fd)
    finally:
        os.close(fd)
    return h.hexdigest(), chunks


def fsync_dir(d):
    fd = os.open(d, os.O_RDONLY)
    try:
        fullfsync(fd)
    finally:
        os.close(fd)


def run(d, ledger, maxbytes):
    stop = []
    signal.signal(signal.SIGTERM, lambda *_: stop.append(1))  # finish the current operation, then exit
    rnd = random.Random()
    state = {}  # relative path -> (sha, size) of completed operations
    led = open(ledger, "a", buffering=1)
    n = 0

    def log(**kw):
        led.write(json.dumps(kw) + "\n")
        led.flush()

    while not stop:
        total = sum(s for _, s in state.values())
        r = rnd.random()
        if state and (total > maxbytes or r < 0.2):
            rel = rnd.choice(sorted(state))
            log(op="begin", kind="delete", path=rel)
            os.unlink(os.path.join(d, rel))
            fsync_dir(d)
            del state[rel]
            log(op="done", sha=None)
        elif state and r < 0.5:
            rel = rnd.choice(sorted(state))
            size = rnd.choice([4096, 65536, rnd.randrange(1 << 20, 48 << 20)])
            log(op="begin", kind="overwrite", path=rel)
            sha, chunks = write_file(os.path.join(d, rel), size, "w")
            fsync_dir(d)
            state[rel] = (sha, size)
            log(op="done", sha=sha, size=size, chunks=chunks)
        else:
            rel = "f%06d_%d" % (n, rnd.randrange(10**6))
            size = rnd.choice([4096, 16384, 65536, rnd.randrange(1 << 20, 64 << 20)])
            log(op="begin", kind="create", path=rel)
            sha, chunks = write_file(os.path.join(d, rel), size, "w")
            fsync_dir(d)
            state[rel] = (sha, size)
            log(op="done", sha=sha, size=size, chunks=chunks)
        n += 1


def diagnose(path, size, chunks):
    """Where does a file that should be intact differ: size, bad 1 MiB chunks, all-zero?"""
    out = " (size %s, expected %s" % (os.path.getsize(path), size)
    if chunks:
        bad, zero = [], 0
        with open(path, "rb") as f:
            for i, want in enumerate(chunks):
                c = f.read(1 << 20)
                if hashlib.sha1(c).hexdigest()[:8] != want:
                    bad.append(i)
                    zero += c.count(0) == len(c) and len(c) > 0
        out += "; %d of %d MiB chunks differ: %s; %d of them all zeros" % (len(bad), len(chunks), bad[:20], zero)
    return out + ")"


def verify(d, ledger):
    state, inflight, chunkmap = {}, None, {}
    with open(ledger) as f:
        for line in f:
            try:
                e = json.loads(line)
            except ValueError:
                continue  # last line cut short
            if e["op"] == "begin":
                inflight = e
            else:
                if inflight["kind"] == "delete":
                    state.pop(inflight["path"], None)
                else:
                    state[inflight["path"]] = e["sha"]
                    chunkmap[inflight["path"]] = (e.get("size"), e.get("chunks"))
                inflight = None
    bad = []
    skip = inflight["path"] if inflight else None
    for rel, sha in sorted(state.items()):
        if rel == skip:
            continue
        p = os.path.join(d, rel)
        if not os.path.exists(p):
            bad.append("missing " + rel)
        elif sha_of(p) != sha:
            bad.append("content differs " + rel + diagnose(p, *chunkmap.get(rel, (None, None))))
    for rel in sorted(os.listdir(d)):
        if rel not in state and rel != skip:
            bad.append("unexpected " + rel)
    done = sum(1 for _ in state)
    print("verified %d files, in flight: %s" % (done, inflight and "%s %s" % (inflight["kind"], inflight["path"])))
    for b in bad:
        print("MISMATCH", b)
    return 1 if bad else 0


if __name__ == "__main__":
    mode, d, ledger = sys.argv[1:4]
    if mode == "run":
        run(d, ledger, int(sys.argv[4]) if len(sys.argv) > 4 else 3 << 30)
    else:
        sys.exit(verify(d, ledger))
