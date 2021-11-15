//
//  AppBranding.swift
//  Dating iOS
//
//  Created by HaiLe on 5/10/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class AppBranding: NSObject {
    static let buttonCornerRadius: CGFloat = 14
    
    // Fonts
    static let boldFont = UIFont(name: "Helvetica-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
    static let baseFont = UIFont(name: "Helvetica", size: 15) ?? UIFont.systemFont(ofSize: 15)
    static let bigFont = UIFont(name: "Helvetica", size: 25) ?? UIFont.systemFont(ofSize: 25)
    static let smallFont = UIFont(name: "Helvetica", size: 12) ?? UIFont.systemFont(ofSize: 12)
    
    // Cell Font
    enum UITableViewCellFont {
        case titleLabelBold
        case titleLabel
        case contentLabel
        case timeStampLabel
        var font: UIFont {
            get {
                switch self {
                case .titleLabelBold:
                    return UIFont(name: "Helvetica-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
                case .titleLabel:
                    return UIFont(name: "Helvetica", size: 13) ?? UIFont.systemFont(ofSize: 13)
                case .contentLabel:
                    return UIFont(name: "Helvetica", size: 12) ?? UIFont.systemFont(ofSize: 12)
                case .timeStampLabel:
                    return UIFont(name: "Helvetica", size: 12) ?? UIFont.systemFont(ofSize: 12)
                }
            }
        }
    }
    
    // Cell Font
    enum UITableViewHeaderFooterViewFont {
        case titleLabelBold
        case subTitleLabel
        var font: UIFont {
            get {
                switch self {
                case .titleLabelBold:
                    return UIFont(name: "Helvetica-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
                case .subTitleLabel:
                    return UIFont(name: "Helvetica", size: 13) ?? UIFont.systemFont(ofSize: 13)
                }
            }
        }
    }
    
    class func customizeOnAppLoad() {
        IQKeyboardManager.shared.enable = true
        let attrs = [
            NSAttributedString.Key.foregroundColor: ColorName.navigationBarTitleColor
        ]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ColorName.navigationBarColor
            appearance.titleTextAttributes = attrs
            UINavigationBar.appearance().standardAppearance = appearance;
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = ColorName.navigationBarColor
        }
        UINavigationBar.appearance().largeTitleTextAttributes = attrs
        UINavigationBar.appearance().tintColor = ColorName.navigationBarTintColor
        UIToolbar.appearance().tintColor = ColorName.navigationBarColor
        UINavigationBar.appearance().titleTextAttributes = attrs
    }
    
    /* Customizes every view controller on load */
    class func customizeOnViewDidLoad(_ viewController: UIViewController) {
        if let _ = viewController.navigationController {
            // configure navigation bar here, to do some more fancy things
        }
        // changes color of active elements like buttons and segments, unfortunately alertview cannot be costumized
        UIApplication.shared.keyWindow?.tintColor = ColorName.mainColor
    }
}
