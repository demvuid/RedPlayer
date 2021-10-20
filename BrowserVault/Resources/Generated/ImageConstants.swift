// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Browser {
    internal static let backIcon = ImageAsset(name: "Browser/backIcon")
    internal static let forwardIcon = ImageAsset(name: "Browser/forwardIcon")
    internal static let iconBrowserFavorites = ImageAsset(name: "Browser/icon_browser_favorites")
    internal static let iconBrowserHistory = ImageAsset(name: "Browser/icon_browser_history")
    internal static let iconNewsFollowing = ImageAsset(name: "Browser/icon_news_following")
  }
  internal enum Folder {
    internal static let folder = ImageAsset(name: "Folder/folder")
    internal static let lockOutline = ImageAsset(name: "Folder/lock_outline")
  }
  internal enum General {
    internal static let baselineManageAccounts = ImageAsset(name: "General/baseline_manage_accounts")
    internal static let icSearchWeb = ImageAsset(name: "General/ic_search_web")
    internal static let iconClose = ImageAsset(name: "General/icon_close")
    internal static let iconTick = ImageAsset(name: "General/icon_tick")
    internal static let info = ImageAsset(name: "General/info")
    internal static let rightChevron = ImageAsset(name: "General/right_chevron")
  }
  internal enum Player {
    internal static let btnFullExit = ImageAsset(name: "Player/btn_full_exit")
    internal static let btnFullInvisible = ImageAsset(name: "Player/btn_full_invisible")
    internal static let btnFullPause = ImageAsset(name: "Player/btn_full_pause")
    internal static let btnFullPlay = ImageAsset(name: "Player/btn_full_play")
    internal static let btnFullPlayDef = ImageAsset(name: "Player/btn_full_play_def")
    internal static let btnFullPlayHl = ImageAsset(name: "Player/btn_full_play_hl")
    internal static let btnFullVisible = ImageAsset(name: "Player/btn_full_visible")
    internal static let btnFullVoice = ImageAsset(name: "Player/btn_full_voice")
    internal static let btnFullVoiceMute = ImageAsset(name: "Player/btn_full_voice_mute")
    internal static let btnToolbarFullScreen = ImageAsset(name: "Player/btn_toolbar_full_screen")
    internal static let btnToolbarInvisible = ImageAsset(name: "Player/btn_toolbar_invisible")
    internal static let btnToolbarPause = ImageAsset(name: "Player/btn_toolbar_pause")
    internal static let btnToolbarPlay = ImageAsset(name: "Player/btn_toolbar_play")
    internal static let btnToolbarVisible = ImageAsset(name: "Player/btn_toolbar_visible")
    internal static let btnToolbarVoice = ImageAsset(name: "Player/btn_toolbar_voice")
    internal static let btnToolbarVoiceMute = ImageAsset(name: "Player/btn_toolbar_voice_mute")
    internal static let btnVideoPlayDef = ImageAsset(name: "Player/btn_video_play_def")
    internal static let btnVideoPlayHl = ImageAsset(name: "Player/btn_video_play_hl")
    internal static let icSliderThumb = ImageAsset(name: "Player/ic_slider_thumb")
    internal static let icVideoBuffering = ImageAsset(name: "Player/ic_video_buffering")
    internal static let iconPlayGreen = ImageAsset(name: "Player/icon_play_green")
    internal static let iconPlayerFastBackward = ImageAsset(name: "Player/icon_player_fast_backward")
    internal static let iconPlayerFastForward = ImageAsset(name: "Player/icon_player_fast_forward")
    internal static let iconPlayerMaximize = ImageAsset(name: "Player/icon_player_maximize")
    internal static let iconPlayerMinimize = ImageAsset(name: "Player/icon_player_minimize")
  }
  internal enum Tabbar {
    internal static let icFileDownload = ImageAsset(name: "Tabbar/ic_file_download")
    internal static let icPlus = ImageAsset(name: "Tabbar/ic_plus")
    internal static let iconBrowser = ImageAsset(name: "Tabbar/icon_browser")
    internal static let iconFolder = ImageAsset(name: "Tabbar/icon_folder")
    internal static let iconSettings = ImageAsset(name: "Tabbar/icon_settings")
    internal static let realityTvShow = ImageAsset(name: "Tabbar/reality_tv_show")
  }
  internal enum Tutorial {
    internal static let tutorial1 = ImageAsset(name: "Tutorial/tutorial1")
    internal static let tutorial2 = ImageAsset(name: "Tutorial/tutorial2")
    internal static let tutorial3 = ImageAsset(name: "Tutorial/tutorial3")
  }
  internal enum Youtube {
    internal static let icFilterVariant = ImageAsset(name: "Youtube/ic_filter_variant")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
