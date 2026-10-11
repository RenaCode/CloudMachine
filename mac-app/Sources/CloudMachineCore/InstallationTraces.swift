import Foundation

/// What this Mac remembers of a backup it has already made - read from the
/// local disk, without rclone and without Google.
///
/// The decisions that can orphan a backup (which Drive folder to use, whether
/// to create an image) used to rest on one witness: what rclone answered with
/// the current configuration. That witness can be wrong without failing. A
/// missing `rclone.conf` makes `rclone listremotes` succeed with an empty list
/// (checked: exit 0), and a token with the `drive.file` scope makes a folder
/// created under another `client_id` simply not there (`directory not found`).
/// Both read as "nothing here yet", and both lead to a new, empty backup next
/// to the real one. These traces are the second witness: they exist only
/// where a mount of this remote really ran.
public enum InstallationTraces {

  /// Folders of `remoteRoot` that a mount of `remoteName` has cached on this
  /// Mac - `cache/vfs/<remote>/CloudMachine/<folder>`.
  ///
  /// rclone names the cache directory after the remote, with a suffix when
  /// the mount overrides backend options: on this project's own Mac it is
  /// `gdrive{hekjD}`, not `gdrive`. Both forms are accepted, and nothing
  /// else - `gdrive2` is another remote.
  ///
  /// rclone creates the directory only once the remote has been opened, so
  /// a mount that failed for want of a remote leaves none.
  public static func cachedFolders(
    cacheDir: URL = DriveBufferService.cacheDir,
    remoteName: String = DriveBufferService.remoteName,
    remoteRoot: String = DriveBufferService.remoteRoot
  ) -> [String] {
    let fm = FileManager.default
    let vfs = cacheDir.appendingPathComponent("vfs")
    guard let remotes = try? fm.contentsOfDirectory(atPath: vfs.path) else { return [] }
    var folders: [String] = []
    for remote in remotes where remote == remoteName || remote.hasPrefix(remoteName + "{") {
      let root = vfs.appendingPathComponent(remote).appendingPathComponent(remoteRoot)
      let names = (try? fm.contentsOfDirectory(atPath: root.path)) ?? []
      folders += names.filter { DriveFolder.isValid($0) }
    }
    return Array(Set(folders)).sorted()
  }

  /// The cached copy of `folder`'s image, if a mount has ever held it.
  public static func cachedImage(
    folder: String, imageName: String,
    cacheDir: URL = DriveBufferService.cacheDir,
    remoteName: String = DriveBufferService.remoteName,
    remoteRoot: String = DriveBufferService.remoteRoot
  ) -> URL? {
    let fm = FileManager.default
    let vfs = cacheDir.appendingPathComponent("vfs")
    guard let remotes = try? fm.contentsOfDirectory(atPath: vfs.path) else { return nil }
    for remote in remotes.sorted() where remote == remoteName || remote.hasPrefix(remoteName + "{")
    {
      let image = vfs.appendingPathComponent(remote).appendingPathComponent(remoteRoot)
        .appendingPathComponent(folder).appendingPathComponent("\(imageName).sparsebundle")
      if fm.fileExists(atPath: image.path) { return image }
    }
    return nil
  }

  // MARK: - The image this Mac has used

  /// Written when an image is created or attached: the Drive path of the
  /// image this Mac backs up to. Unlike the cache it survives clearing the
  /// buffer.
  public static var knownImageFile: URL {
    CMPaths.appSupportDir.appendingPathComponent("known-image")
  }

  /// Remembers that the image at `remotePath` exists. Best effort: a failed
  /// write leaves the cache trace as the only witness, as before.
  public static func rememberImage(
    remotePath: String = DriveBufferService.remotePath, file: URL = knownImageFile
  ) {
    let line = "\(DriveBufferService.remoteName):\(remotePath)"
    if (try? String(contentsOf: file, encoding: .utf8))?
      .trimmingCharacters(in: .whitespacesAndNewlines) == line
    {
      return
    }
    try? line.write(to: file, atomically: true, encoding: .utf8)
  }

  /// Where this Mac keeps proof that the image of `folder` has existed -
  /// `nil` when it keeps none. A path, so a refusal can say what to remove
  /// when the image really was deleted on purpose.
  public static func knownImageTrace(
    folder: String = DriveFolder.name,
    imageName: String = BackupImageService.imageName,
    remotePath: String = DriveBufferService.remotePath,
    knownImageFile: URL = knownImageFile,
    cacheDir: URL = DriveBufferService.cacheDir
  ) -> String? {
    let remembered = (try? String(contentsOf: knownImageFile, encoding: .utf8))?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    if remembered == "\(DriveBufferService.remoteName):\(remotePath)" {
      return knownImageFile.path
    }
    return cachedImage(folder: folder, imageName: imageName, cacheDir: cacheDir)?.path
  }
}
