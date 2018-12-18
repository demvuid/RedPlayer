// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Browser {
    /// Browser
    internal static let title = L10n.tr("Localizable", "browser.title")
  }

  internal enum Folder {
    /// Folder
    internal static let title = L10n.tr("Localizable", "folder.title")
    internal enum Cover {
      /// Cover Photo
      internal static let photo = L10n.tr("Localizable", "folder.cover.photo")
    }
    internal enum Create {
      /// Create Folder
      internal static let title = L10n.tr("Localizable", "folder.create.title")
    }
    internal enum Name {
      /// Input Folder Name
      internal static let placeholder = L10n.tr("Localizable", "folder.name.placeholder")
      /// Folder Name
      internal static let title = L10n.tr("Localizable", "folder.name.title")
    }
  }

  internal enum Generic {
    /// New
    internal static let new = L10n.tr("Localizable", "generic.new")
    /// Next
    internal static let next = L10n.tr("Localizable", "generic.next")
    /// Save
    internal static let save = L10n.tr("Localizable", "generic.save")
    /// Search
    internal static let search = L10n.tr("Localizable", "generic.search")
    /// Start
    internal static let start = L10n.tr("Localizable", "generic.start")
    /// Success
    internal static let success = L10n.tr("Localizable", "generic.success")
    /// Unknown
    internal static let unknown = L10n.tr("Localizable", "generic.unknown")
    /// View more
    internal static let viewmore = L10n.tr("Localizable", "generic.viewmore")
    internal enum Button {
      internal enum Title {
        /// Add
        internal static let add = L10n.tr("Localizable", "generic.button.title.add")
        /// Back
        internal static let back = L10n.tr("Localizable", "generic.button.title.back")
        /// Cancel
        internal static let cancel = L10n.tr("Localizable", "generic.button.title.cancel")
        /// Done
        internal static let done = L10n.tr("Localizable", "generic.button.title.done")
        /// Home
        internal static let home = L10n.tr("Localizable", "generic.button.title.home")
        /// No
        internal static let no = L10n.tr("Localizable", "generic.button.title.no")
        /// OK
        internal static let ok = L10n.tr("Localizable", "generic.button.title.ok")
        /// Yes
        internal static let yes = L10n.tr("Localizable", "generic.button.title.yes")
      }
    }
    internal enum Error {
      internal enum Alert {
        /// Error
        internal static let title = L10n.tr("Localizable", "generic.error.alert.title")
      }
    }
  }

  internal enum Passcode {
    /// Use 4-digit Passcode Instead
    internal static let change4digit = L10n.tr("Localizable", "passcode.change4digit")
    /// Use 6-digit Passcode Instead
    internal static let change6digit = L10n.tr("Localizable", "passcode.change6digit")
    /// Create a passcode
    internal static let create = L10n.tr("Localizable", "passcode.create")
    /// Enable Passcode
    internal static let enable = L10n.tr("Localizable", "passcode.enable")
    /// Passcodes did not match. Try again.
    internal static let notmatch = L10n.tr("Localizable", "passcode.notmatch")
    /// Passcode
    internal static let title = L10n.tr("Localizable", "passcode.title")
    internal enum Biometry {
      /// Authenticate with Face ID
      internal static let faceid = L10n.tr("Localizable", "passcode.biometry.faceid")
      /// Unlock access to %@ app
      internal static func reason(_ p1: String) -> String {
        return L10n.tr("Localizable", "passcode.biometry.reason", p1)
      }
      /// Authenticate with Touch ID
      internal static let touchid = L10n.tr("Localizable", "passcode.biometry.touchid")
      /// The device is not support Face ID or Touch ID
      internal static let unavaiable = L10n.tr("Localizable", "passcode.biometry.unavaiable")
      internal enum Authenticate {
        /// Failed to authenticate
        internal static let failed = L10n.tr("Localizable", "passcode.biometry.authenticate.failed")
      }
    }
    internal enum Change {
      /// Change Passcode
      internal static let title = L10n.tr("Localizable", "passcode.change.title")
    }
    internal enum Create {
      /// Use this passcode to unlock %@ app
      internal static func description(_ p1: String) -> String {
        return L10n.tr("Localizable", "passcode.create.description", p1)
      }
      /// Enter your passcode
      internal static let enter = L10n.tr("Localizable", "passcode.create.enter")
      /// Verify your new passcode
      internal static let verify = L10n.tr("Localizable", "passcode.create.verify")
    }
    internal enum Enter {
      /// Enter Pin
      internal static let pin = L10n.tr("Localizable", "passcode.enter.pin")
    }
  }

  internal enum Settings {
    /// Settings
    internal static let title = L10n.tr("Localizable", "settings.title")
    internal enum About {
      /// About
      internal static let title = L10n.tr("Localizable", "settings.about.title")
    }
    internal enum Browser {
      /// Browser's default URL
      internal static let title = L10n.tr("Localizable", "settings.browser.title")
      internal enum Search {
        /// Search Engine
        internal static let engine = L10n.tr("Localizable", "settings.browser.search.engine")
      }
      internal enum Url {
        /// Custom URL
        internal static let custom = L10n.tr("Localizable", "settings.browser.url.custom")
        /// Input URL
        internal static let input = L10n.tr("Localizable", "settings.browser.url.input")
        /// Please enter a valid URL.
        internal static let `required` = L10n.tr("Localizable", "settings.browser.url.required")
        /// Set Default URL
        internal static let `set` = L10n.tr("Localizable", "settings.browser.url.set")
      }
    }
    internal enum Email {
      /// Email to feedback
      internal static let title = L10n.tr("Localizable", "settings.email.title")
    }
    internal enum Help {
      /// Help
      internal static let title = L10n.tr("Localizable", "settings.help.title")
    }
    internal enum Lock {
      /// Lock settings
      internal static let title = L10n.tr("Localizable", "settings.lock.title")
      internal enum Passcode {
        /// Active Passcode
        internal static let active = L10n.tr("Localizable", "settings.lock.passcode.active")
        /// Change Passcode
        internal static let change = L10n.tr("Localizable", "settings.lock.passcode.change")
      }
    }
    internal enum Review {
      /// Review
      internal static let title = L10n.tr("Localizable", "settings.review.title")
    }
    internal enum Share {
      /// Share
      internal static let title = L10n.tr("Localizable", "settings.share.title")
    }
    internal enum Version {
      /// Restore previous purchases
      internal static let restore = L10n.tr("Localizable", "settings.version.restore")
      /// Version
      internal static let title = L10n.tr("Localizable", "settings.version.title")
      /// Upgrade to remove ads
      internal static let upgrade = L10n.tr("Localizable", "settings.version.upgrade")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
