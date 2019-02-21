import UIKit
import SVPullToRefresh

let intervalUpdate = Double(24 * 3600)
let margin: CGFloat = 5.0

class PageYoutubeItem: PageItem {
    var category: MenuCategory!
    init(category: MenuCategory!) {
        super.init()
        self.category = category
        self.itemId = self.category.categoryId
    }
}

protocol YoutubeViewControllerDelegate {
    func playYoutubeItem(_ item: YoutubeItem)
}
class YoutubeViewController: PageViewController {
    @IBOutlet weak var collectionView: BaseCollectionView!
    var items = [YoutubeItem]()
    var nextToken: String = ""
    var delegate: YoutubeViewControllerDelegate!
    
    var pageYoutubeItem: PageYoutubeItem!
    override var pageItem: PageItem! {
        get {
            return pageYoutubeItem
        }
        set {
            if newValue is PageYoutubeItem {
                pageYoutubeItem = newValue as? PageYoutubeItem
            } else {
                Logger.debug("incorrect PageYoutubeItem type")
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.brandingUI()
        self.listYoutube()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func brandingUI() {
        self.collectionView.register(cellType: ThumbnailTitleCollectionViewCell.self)
    }
    
    func addPullToRefreshToView() {
        self.collectionView.addPullToRefresh {
            [weak self] in
            self?.collectionView.showsInfiniteScrolling = false
            self?.collectionView.pullToRefreshView.startAnimating()
            if let category = self?.pageYoutubeItem?.category {
                ModelMgr.updateObject({
                    category.nextToken = ""
                    category.items.removeAll()
                })
            }
            
            self?.listYoutube()
        }
    }
    
    func addInfiniteScrollingToView(_ handleResult: @escaping HandlerYoutubeAPI) {
        self.collectionView.addInfiniteScrolling(actionHandler: {
            [unowned self] in
            if self.collectionView.showsInfiniteScrolling {
                self.collectionView.infiniteScrollingView.activityIndicatorViewStyle = .white
                self.collectionView.infiniteScrollingView.startAnimating()
                
                var pageNextToken: String = ""
                if self.nextToken != "" {
                    pageNextToken = self.nextToken
                }
                YoutubeService.sharedInstance.listYoutubeByCategory(self.pageYoutubeItem.category, nextToken: pageNextToken, withCompletionBlock: handleResult)
            }
            
        })
    }
    
    func loadMoreYoutubeItems() {
        if self.collectionView.showsInfiniteScrolling {
            self.fetchListYoutube()
        }
    }
    
    func listYoutube() {
        if self.collectionView.pullToRefreshView == nil {
            self.addPullToRefreshToView()
        }
        if pageYoutubeItem != nil && pageYoutubeItem.category != nil {
            let categories = ModelMgr.fetchObjects(MenuCategory.self, filter: NSPredicate(format: "categoryId = %@", self.pageYoutubeItem.category.categoryId))
            var menuCategory: MenuCategory!
            if categories.count > 0 {
                menuCategory = categories.first!
            } else {
                menuCategory = pageYoutubeItem.category
            }
            if let category = menuCategory {
                if let lastestDate = self.pageYoutubeItem.category.dateUpdated {
                    let timestamp = fabs(lastestDate.timeIntervalSinceNow)
                    if timestamp >  intervalUpdate{
                        ModelMgr.updateObject({
                            category.nextToken = ""
                            category.items.removeAll()
                        })
                    }
                }
                self.nextToken = category.nextToken
                self.items.removeAll()
                self.items.append(contentsOf: category.items.map({$0}))
                self.pageYoutubeItem.category = category
                self.collectionView.reloadData()
                if self.items.count == 0 || self.nextToken != "" {
                    self.fetchListYoutube()
                }
                
            }
        }
    }
    
    func fetchListYoutube() {
        let block: HandlerYoutubeAPI = {
            [weak self] (youtubeResult: YouTubeResult?, error: Error?) in
            if let self = self {
                if let youtubeResult = youtubeResult  {
                    if self.items.count == 0 {
                        if youtubeResult.items.count > 0 {
                            self.items.append(contentsOf: youtubeResult.items.map({$0}))
                        }
                        self.collectionView.reloadData()
                    } else {
                        var indexSet = [IndexPath]()
                        for index in self.items.count ..< (self.items.count + youtubeResult.items.count) {
                            indexSet.append(IndexPath(item: index, section: 0))
                        }
                        if youtubeResult.items.count > 0 {
                            self.items.append(contentsOf: youtubeResult.items.map({$0}))
                        }
                        if indexSet.count > 0 {
                            self.collectionView.insertItems(at: indexSet)
                        }
                    }
                    self.nextToken = youtubeResult.tokenRequestNextPage
                    self.collectionView.showsInfiniteScrolling = youtubeResult.hasNextToken()

                    if let category = self.pageYoutubeItem.category {
                        ModelMgr.updateObject(
                            {
                                if category.items.count == 0 {
                                    category.dateUpdated = Date()
                                }
                                category.nextToken = youtubeResult.tokenRequestNextPage
                                category.items.append(objectsIn: youtubeResult.items)
                        })
                        self.pageYoutubeItem.category = category
                    }
                    
                }
                if self.collectionView.infiniteScrollingView != nil {
                    self.collectionView.infiniteScrollingView.stopAnimating()
                }
                
                if self.collectionView.pullToRefreshView != nil {
                    self.collectionView.pullToRefreshView.stopAnimating()
                }
            }
        }
        if self.collectionView.infiniteScrollingView == nil {
            self.addInfiniteScrollingToView(block);
        }
        
        var pageNextToken: String = ""
        if self.nextToken != "" {
            pageNextToken = self.nextToken
        }
        YoutubeService.sharedInstance.listYoutubeByCategory(self.pageYoutubeItem.category, nextToken: pageNextToken, withCompletionBlock: block)
    }
    
    func playYoutubeItemIndex(_ index: Int) {
        let item = self.items[index]
        if self.delegate != nil {
            self.delegate.playYoutubeItem(item)
        }
    }
}

extension YoutubeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: String(describing: ThumbnailTitleCollectionViewCell.self), for: indexPath) as! ThumbnailTitleCollectionViewCell
        let item = self.items[indexPath.row]
        
        let menuItem = MenuItem(name: item.title, iconName: nil, iconUrl: item.thumnailMediumUrl)
        cell.configData(menuItem)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.playYoutubeItemIndex(indexPath.row)
    }
}

extension YoutubeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame : CGRect = collectionView.frame
        var numberItemsOfRow: CGFloat = 2
        var widthTotal = frame.width
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            numberItemsOfRow = 3
            
            if UIDevice.isLandscape {
                widthTotal = self.view.frame.size.height
            }
        }
        let width = (widthTotal - margin*(numberItemsOfRow+1)) / numberItemsOfRow
        let height = width
        return CGSize(width: width, height: height);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // margin between cells
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
}

