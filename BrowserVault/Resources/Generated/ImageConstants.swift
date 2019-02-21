// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

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
  internal enum Youtube {

    internal static let icFilterVariant = ImageAsset(name: "Youtube/ic_filter_variant")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
