# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BrowserVault' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BrowserVault
# Networking
pod 'Alamofire', '4.8.1'
# Architecture
pod 'Viperit', '1.2.0'
# Utilities
pod 'SnapKit', '4.2.0'
pod 'SwiftGen'
pod 'KeychainAccess'
pod 'CocoaLumberjack/Swift', '3.4.2'
#pod 'Google-Mobile-Ads-SDK'
pod 'InAppPurchase'
pod 'SwiftyStoreKit'
pod 'MZDownloadManager'
pod 'YoutubeDirectLinkExtractor', :git => 'https://github.com/OscarVernis/YoutubeDirectLinkExtractor.git' 
# UI
pod 'SVPullToRefresh'
pod 'MBProgressHUD'
pod 'IQKeyboardManagerSwift'
pod 'Reusable'
pod 'Eureka'
pod 'UICircularProgressRing', '4.1.0'
pod 'DKImagePickerController', :subspecs => ['PhotoGallery', 'Camera']
pod 'NotificationBannerSwift', '2.0.1'
pod 'PageMenu', :git => 'https://github.com/orazz/PageMenu.git'

# Database
pod 'RealmSwift'
# Rx
pod 'RxSwift'
pod 'RxCocoa'
# Player
pod 'MobileVLCKit'
pod 'Reachability'

pod 'Siren'

pod 'ReviewKit'

  target 'BrowserVaultTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BrowserVaultUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

#post_install do |installer|
#    swift4Targets = ['PageMenu']
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
#            config.build_settings['SWIFT_VERSION'] = '4.2'
#            if config.name == 'Debug'
#                config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
#                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
#            end
#        end
#        if swift4Targets.include? target.name
#            target.build_configurations.each do |config|
#                config.build_settings['SWIFT_VERSION'] = '4.0'
#            end
#        end
#    end
#end
