//
//  BaseTableViewCell.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/16/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import Reusable
private let heightDetailView: CGFloat = 49

enum BaseTableViewCellStyle: String {
    case basic = "BaseBasicTableViewCell"
    case basicRightValue = "BaseBasicRightValueTableViewCell"
    case basicAndImage = "BaseBasicAndImageTableViewCell"
    case basicDetailViewAndImage = "BaseBasicDetailViewAndImageTableViewCell"
    case subTitle = "BaseSubTitleTableViewCell"
    case subTitleAndImage = "BaseSubTitleAndImageTableViewCell"
    case subTitleRightValueAndImage = "BaseSubTitleRightValueAndImageTableViewCell"
    case textView = "BaseTextViewTableViewCell"
    
    static let array = [basic, basicRightValue, basicAndImage, basicDetailViewAndImage,
                        subTitle, subTitleAndImage, subTitleRightValueAndImage,
                        textView]
    
    static let allValues: [String] = BaseTableViewCellStyle.array.map { (value: BaseTableViewCellStyle) -> String in
        return value.rawValue
    }
}

class BaseTableViewCell: UITableViewCell, Reusable, NibLoadable {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var rightValueLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var heightConstraintDetailView: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderTextView: UILabel!
    @IBOutlet weak var heightConstraintTextView: NSLayoutConstraint!
    
    class func registerStandardCellsToTableView(_ tableView: UITableView) {
        for identifier in BaseTableViewCellStyle.allValues {
            BaseTableViewCell.registerNibName(identifier, toTableView: tableView, cellReuseIdentifier: identifier)
        }
    }
    
    class func registerNibName(_ nibName: String, toTableView tableView: UITableView, cellReuseIdentifier: String) {
        tableView.register(UINib.init(nibName: nibName, bundle: Bundle.main), forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if self.textLabel != nil {
            self.textLabel!.font = AppBranding.UITableViewCellFont.titleLabel.font
            self.textLabel?.textColor = ColorName.titleColor
        }
        if self.detailTextLabel != nil {
            self.detailTextLabel!.font = AppBranding.UITableViewCellFont.timeStampLabel.font
            self.detailTextLabel?.textColor = ColorName.titleColor
        }
        if self.titleLabel != nil {
            self.titleLabel.font = AppBranding.UITableViewCellFont.titleLabel.font
            self.titleLabel.textColor = ColorName.titleColor
        }
        if self.subTitleLabel != nil {
            self.subTitleLabel.font = AppBranding.UITableViewCellFont.timeStampLabel.font
            self.subTitleLabel.textColor = ColorName.titleColor
        }
        if self.rightValueLabel != nil {
            self.rightValueLabel.font = AppBranding.UITableViewCellFont.timeStampLabel.font
            self.rightValueLabel.textColor = ColorName.titleColor
        }
        if self.textView != nil {
            self.textView.font = AppBranding.UITableViewCellFont.timeStampLabel.font
            self.textView.textColor = ColorName.titleColor
        }
        if self.placeHolderTextView != nil {
            self.placeHolderTextView.font = AppBranding.UITableViewCellFont.timeStampLabel.font
            self.placeHolderTextView.textColor = ColorName.titleColor
        }
        if detailView != nil {
            self.heightConstraintDetailView.constant = 0.0
        }
        
    }
    
    func updateLayoutIfNeed() {
        self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.accessoryView = nil
        self.imageView?.image = nil
        if self.textLabel != nil {
            self.textLabel?.text = ""
        }
        if self.detailTextLabel != nil {
            self.detailTextLabel?.text = ""
        }
        if self.titleLabel != nil {
            self.titleLabel?.text = ""
        }
        if self.subTitleLabel != nil {
            self.subTitleLabel?.text = ""
        }
        if self.rightValueLabel != nil {
            self.rightValueLabel?.text = ""
        }
        if self.textView != nil {
            self.textView.text = ""
        }
        if self.placeHolderTextView != nil {
            self.placeHolderTextView.text = ""
        }
        
        if detailView != nil {
            self.heightConstraintDetailView.constant = 0.0
            self.detailView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
        }
    }
    
    func showContentDetailView(_ contentView: UIView) {
        if detailView != nil {
            self.heightConstraintDetailView.constant = heightDetailView
            self.detailView.addSubview(contentView)
            var rect = self.detailView.frame
            rect.size.height = heightDetailView
            rect.origin.y = 0
            contentView.frame = rect
        }
    }
    
    func updateTextViewAttributedString(attributedString: NSAttributedString) {
        self.textView.attributedText = attributedString
        self.updateConstraintsTextView()
    }
    
    func updateTextViewString(text: String) {
        self.textView.text = text
        self.updateConstraintsTextView()
    }
    
    func updateConstraintsTextView() {
        self.heightConstraintTextView.constant = self.textView.contentSize.height
        self.setNeedsLayout()
        self.layoutIfNeeded()
        var rect:CGRect = self.frame;
        rect.size.height = self.textView.contentSize.height
        self.frame = rect;
    }
}

