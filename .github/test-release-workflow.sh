#!/usr/bin/env bash
# Guard for .github/workflows/release.yml: a release (GitHub Release, tag, cask
# pushed to the Homebrew tap, signing certificate imported) happens only from
# main or from a vX.Y.Z tag on a commit that is on main.
#
# "Run workflow" can be started on any branch, and a tag can be pushed on any
# commit. Before this guard a manual run on a feature branch computed
# release=true and published unmerged code to every `brew upgrade`.
#
# This guards against mistakes, not against someone with push access: a run
# uses the workflow file of its own ref, which that ref can change. The hard
# stop is repository settings (an environment limited to main and v* tags
# holding the secrets, a ruleset on v* tags).
#
# Two kinds of checks:
#   - the `decide` step's script is extracted from the workflow and RUN with a
#     stub `git`, for each kind of ref (behaviour, not text);
#   - the release job's IS_RELEASE also requires main or a tag (second guard,
#     independent of decide), and every step that publishes or reads a secret
#     is gated on it.
#
# No YAML parser: plain bash + awk, so it runs on any runner.
# Usage: .github/test-release-workflow.sh [path-to-release.yml]
set -euo pipefail

F="${1:-.github/workflows/release.yml}"
[ -f "$F" ] || { echo "missing $F"; exit 1; }
CODE="$(grep -v '^[[:space:]]*#' "$F")"
fail=0
ok() { echo "OK   $1"; }
bad() { echo "BAD  $1"; fail=1; }

work="$(mktemp -d "${TMPDIR:-/tmp}/release-wf.XXXXXX")"
trap 'rm -rf "$work"' EXIT

# --- decide: run its script -------------------------------------------------
# The `run: |` block right after `- id: decide`, de-indented.
printf '%s\n' "$CODE" | awk '
  /^[[:space:]]*- id: decide[[:space:]]*$/ { found = 1; next }
  found && !inrun && /^[[:space:]]*run: \|[[:space:]]*$/ {
    inrun = 1; ind = -1; next
  }
  inrun {
    if ($0 ~ /^[[:space:]]*$/) { print ""; next }
    match($0, /^ */); n = RLENGTH
    if (ind < 0) ind = n
    if (n < ind) exit
    print substr($0, ind + 1)
  }' > "$work/decide.sh"
if [ ! -s "$work/decide.sh" ]; then
  bad "decide step script not found"
  echo "FAILED"; exit 1
fi

# Stub git: tags that exist come from STUB_TAGS (space separated, without v).
# STUB_ON_MAIN=yes|no answers `merge-base --is-ancestor`, which must ask about
# the run's own commit against the freshly fetched main - anything else (HEAD,
# a local `main`, another sha) is an error, so a check that compares the wrong
# things cannot pass.
mkdir -p "$work/bin"
cat > "$work/bin/git" <<'STUB'
#!/usr/bin/env bash
case "$1" in
  fetch)
    [ "$*" = "fetch --no-tags origin +refs/heads/main:refs/remotes/origin/main" ] \
      || { echo "stub git: unexpected '$*'" >&2; exit 97; }
    ;;
  merge-base)
    [ "$*" = "merge-base --is-ancestor $GITHUB_SHA refs/remotes/origin/main" ] \
      || { echo "stub git: unexpected '$*'" >&2; exit 97; }
    [ "${STUB_ON_MAIN:-no}" = yes ]
    ;;
  ls-remote)
    shift
    exact=0
    [ "$1" = "--exit-code" ] && { exact=1; shift; }
    while [ "${1#--}" != "$1" ]; do shift; done
    shift # origin
    pattern="${1#refs/tags/v}"
    hit=0
    for t in ${STUB_TAGS:-}; do
      # shellcheck disable=SC2053
      if [[ "$t" == $pattern ]]; then
        echo "0000000000000000000000000000000000000000	refs/tags/v$t"; hit=1
      fi
    done
    [ $exact = 0 ] || [ $hit = 1 ]
    ;;
  *) echo "stub git: unexpected '$*'" >&2; exit 97 ;;
esac
STUB
chmod +x "$work/bin/git"
mkdir -p "$work/repo/mac-app"
echo "1.3.0" > "$work/repo/mac-app/VERSION"

# run_decide EVENT REF ON_MAIN -> prints "rc release skip version"
run_decide() {
  local out="$work/out" rc=0
  : > "$out"
  (
    cd "$work/repo"
    PATH="$work/bin:$PATH" GITHUB_OUTPUT="$out" GITHUB_EVENT_NAME="$1" \
      GITHUB_REF="$2" GITHUB_REF_NAME="${2##*/}" GITHUB_SHA=abc123 \
      STUB_TAGS="1.3.0 1.3.1" STUB_ON_MAIN="$3" \
      bash -e "$work/decide.sh"
  ) > "$work/log" 2>&1 || rc=$?
  local rel skip ver
  rel="$(sed -n 's/^release=//p' "$out")"
  skip="$(sed -n 's/^skip=//p' "$out")"
  ver="$(sed -n 's/^version=//p' "$out")"
  echo "$rc ${rel:-none} ${skip:-none} ${ver:-none}"
}

expect() {
  local what="$1" want="$2" got
  got="$(run_decide "$3" "$4" "$5")"
  if [ "$got" = "$want" ]; then
    ok "$what ($got)"
  else
    bad "$what: want '$want', got '$got'"
    sed 's/^/     /' "$work/log"
  fi
}

# VERSION is 1.3.0 and v1.3.0, v1.3.1 exist, so main releases the next patch.
#                                                     rc release skip version
expect "push to main releases the next patch" "0 true false 1.3.2" push refs/heads/main yes
expect "manual run on main releases" "0 true false 1.3.2" workflow_dispatch refs/heads/main yes
expect "pull request is a dry run" "0 false false 1.3.0" pull_request refs/pull/7/merge no
expect "manual run on a feature branch does NOT release" "0 false false 1.3.0" workflow_dispatch refs/heads/feature/x no
expect "push to another branch does NOT release" "0 false false 1.3.0" push refs/heads/feature/x no
expect "tag on a commit on main releases that version" "0 true false 1.3.5" push refs/tags/v1.3.5 yes
expect "tag on a commit NOT on main fails" "1 none none none" push refs/tags/v1.3.5 no
expect "manual run on a tag NOT on main fails" "1 none none none" workflow_dispatch refs/tags/v1.3.5 no

# --- second guard in the release job ----------------------------------------
release_job="$(printf '%s\n' "$CODE" | awk '
  /^  release:/ { j = 1; next }
  j && /^  [^ ]/ { j = 0 }
  j { print }')"
# Compared whole: any extra `|| ...` would let another ref through.
is_release="$(printf '%s\n' "$release_job" | grep -E '^      IS_RELEASE:' || true)"
want_is_release="      IS_RELEASE: \${{ needs.decide.outputs.release == 'true' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v')) }}"
if [ "$is_release" = "$want_is_release" ]; then
  ok "IS_RELEASE requires decide + (main or v* tag)"
else
  bad "IS_RELEASE: want '${want_is_release#      }', got '${is_release:-none}'"
fi

# --- every step that publishes or reads a secret ----------------------------
# One line per step of the release job: name, if, secret (\037-separated); secret is
# 1 when the step reads a secret or the tap token. The `if:` is found wherever
# it sits in the step (after `id:`, `uses:`, ...).
steps="$(printf '%s\n' "$release_job" | awk '
  function flush() { if (started) printf "%s\037%s\037%d\n", name, cond, sec }
  /^    steps:/ { insteps = 1; next }
  !insteps { next }
  /^      - / { flush(); started = 1; name = ""; cond = ""; sec = 0 }
  !started { next }
  { line = $0; sub(/^      - /, "        ", line) }
  line ~ /^        name: / { name = substr(line, 15) }
  line ~ /^        uses: / && name == "" { name = substr(line, 15) }
  line ~ /^        if: / { cond = substr(line, 13) }
  /secrets\.|steps\.tap-token\./ { sec = 1 }
  END { flush() }')"

for step in "Import signing certificate" "Tap token" "Check tap access" \
  "Check tap app" "Publish GitHub Release" "Push cask to tap"; do
  printf '%s\n' "$steps" | cut -d $'\037' -f1 | grep -qxF "$step" || bad "step '$step' not found in the release job"
done

# The tap token is also taken on pull requests, on purpose: an app that lost
# its installation fails the PR, not the release. Not on Dependabot PRs: they get
# Dependabot secrets only, without TAP_APP_KEY (2026-11-07). Never on a dry run from
# another branch - that branch's code has already run in earlier steps.
TAP_PROBE="env.IS_RELEASE == 'true' || (github.event_name == 'pull_request' && github.event.pull_request.user.login != 'dependabot[bot]')"
# Publishing steps that read no secret themselves: the gate that stops a build
# which changed tracked files, the release action (job token), git push with
# the tap checkout's credentials.
PUBLISHING="Build did not change tracked files|Publish GitHub Release|Check out tap|Push cask to tap"
GATE="env.IS_RELEASE == 'true'"
# \037 (unit separator), not a tab: `read` merges adjacent tabs, so an empty
# `if` would shift the fields.
while IFS=$'\037' read -r name cond sec; do
  [ -n "$name" ] || continue
  case "$name" in
    "Tap token" | "Check tap access")
      if [ "$cond" = "$TAP_PROBE" ]; then
        ok "$name: release or pull request only"
      else
        bad "$name: want 'if: $TAP_PROBE', got '${cond:-no if}'"
      fi
      continue ;;
  esac
  if [ "$sec" = 1 ] || printf '%s\n' "$name" | grep -qxE "$PUBLISHING"; then
    if [ "$cond" = "$GATE" ]; then
      ok "$name: only when IS_RELEASE"
    else
      bad "$name: publishes or reads a secret, want 'if: $GATE', got '${cond:-no if}'"
    fi
  fi
done <<< "$steps"

[ $fail = 0 ] && echo "ALL OK" || echo "FAILED"
exit $fail
