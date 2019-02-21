//
//  BaseMenuCategoriesView.swift
//  Entertainment
//
//  Created by Hai Le on 8/2/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit

protocol BaseMenuCategoriesViewDelegate {
    func menuCategorySwipeToPage(_ page: Int)
}

class BaseMenuCategoriesView: BaseCollectionView {
    var menuItems = [MenuItem]()
    var indexSelect: Int = 0
    var categoryDelegate: BaseMenuCategoriesViewDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.register(cellType: BaseMenuItemCell.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.register(cellType: BaseMenuItemCell.self)
    }
    
    override func setupUI() {
        super.setupUI()
        self.delegate = self
        self.dataSource = self
        self.alwaysBounceHorizontal = true
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }
    
    func loadMenuItems(_ menuItems: [MenuItem]) {
        self.menuItems.removeAll()
        self.menuItems.append(contentsOf: menuItems)
        self.reloadData()
    }
    
    func scrollCategoryToIndex(_ index: Int) {
        if index != indexSelect {
            indexSelect = index
            let indexPath = IndexPath(item: indexSelect, section: 0)
            self.reloadData()
            self.scrollToItem(at: indexPath , at: .centeredHorizontally, animated: true)
        }
    }
    
}

extension BaseMenuCategoriesView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: BaseMenuItemCell.self)
        let menuItem = self.menuItems[(indexPath as NSIndexPath).row]
        cell.configData(menuItem)
        if (indexPath as NSIndexPath).item == indexSelect {
            cell.title.textColor = ColorName.mainColor
        } else {
            cell.title.textColor = UIColor.gray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row != indexSelect {
            
            indexSelect = (indexPath as NSIndexPath).row
            collectionView.reloadData()
            collectionView.scrollToItem(at: indexPath , at: .centeredHorizontally, animated: true)
            if self.categoryDelegate != nil {
                self.categoryDelegate?.menuCategorySwipeToPage(indexSelect)
            }
        }
    }
}

extension BaseMenuCategoriesView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let menuItem = self.menuItems[(indexPath as NSIndexPath).row]
        let width = menuItem.name.widthOfString(usingFont: AppBranding.UITableViewCellFont.titleLabel.font)
        let height = CGFloat(50)
        return CGSize(width: width + 20, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // margin between cells
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
