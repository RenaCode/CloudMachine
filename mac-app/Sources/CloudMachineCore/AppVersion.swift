import Foundation

/// Exactly what the thing that is running right now was built from.
///
/// The version number alone does not answer "is what is installed the same as
/// what is in the repository" - `1.1.0` sits in the VERSION file for months,
/// and the build number (commit count) repeats across branches. That is why we
/// also carry the commit SHA and whether the tree was dirty.
///
/// The reason is concrete: on 13 Sep 2026 the question "is the latest version
/// installed" could not be answered other than by comparing file dates and
/// diffing the git tree against a guessed commit.
public struct AppVersion: Equatable {
  public let shortVersion: String
  public let build: String
  public let commit: String
  public let dirty: Bool

  public init(shortVersion: String, build: String, commit: String, dirty: Bool) {
    self.shortVersion = shortVersion
    self.build = build
    self.commit = commit
    self.dirty = dirty
  }

  /// Value inserted when building outside a git repository.
  ///
  /// Written into Info.plist by `build-app` and read back only by the binary
  /// from that same bundle, so both sides always agree on it.
  public static let unknownCommit = "unknown"

  /// One line for the log and for `--version`.
  public var summary: String {
    var text = "\(shortVersion) (\(build))"
    if commit != Self.unknownCommit {
      text += " \(commit)"
    }
    if dirty {
      text += " " + L10n.tr("DIRTY-TREE")
    }
    return text
  }

  /// Whether a commit in the repository can be pointed at unambiguously.
  ///
  /// A dirty tree means the binary contains code that is in no commit - the
  /// version number then LIES and must not be taken as proof that what is
  /// installed is the same as what is on the branch.
  public var isTraceable: Bool {
    commit != Self.unknownCommit && !dirty
  }
}

public enum AppVersionReader {

  static let commitKey = "CMGitCommit"
  static let dirtyKey = "CMGitDirty"

  /// Pure version - reads from a dictionary, so it can be tested without
  /// building a bundle.
  public static func parse(infoPlist: [String: Any]) -> AppVersion {
    let dirtyRaw = infoPlist[dirtyKey]
    let dirty: Bool
    switch dirtyRaw {
    case let flag as Bool: dirty = flag
    case let text as String: dirty = (text == "true" || text == "YES" || text == "1")
    default: dirty = false
    }
    return AppVersion(
      shortVersion: infoPlist["CFBundleShortVersionString"] as? String ?? "?",
      build: infoPlist["CFBundleVersion"] as? String ?? "?",
      commit: infoPlist[commitKey] as? String ?? AppVersion.unknownCommit,
      dirty: dirty)
  }

  /// Version of the binary that is running RIGHT NOW.
  ///
  /// We look for `Contents/Info.plist` next to the executable rather than going
  /// through `Bundle.main`: the agent is a plain executable in
  /// `Contents/MacOS`, not an application, so `Bundle.main` can point at a
  /// directory instead of the bundle. Under `swift run` there is no bundle at
  /// all and that is not an error - we return `nil`, and the caller says
  /// plainly that this is a build from the working tree.
  public static func current(
    executable: URL = CMPaths.runningExecutable
  ) -> AppVersion? {
    let infoPlist =
      executable
      .deletingLastPathComponent()  // Contents/MacOS
      .deletingLastPathComponent()  // Contents
      .appendingPathComponent("Info.plist")
    guard let data = try? Data(contentsOf: infoPlist),
      let plist = try? PropertyListSerialization.propertyList(
        from: data, options: [], format: nil) as? [String: Any]
    else { return nil }
    return parse(infoPlist: plist)
  }
}
