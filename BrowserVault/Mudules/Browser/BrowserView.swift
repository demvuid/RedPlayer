//
//  BrowserView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/8/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit
import WebKit
import GoogleMobileAds

var estimatedProgressContext = 0
let estimatedProgressKeyPath = "estimatedProgress"
private let titleLoading = "Loading...."
private let unSelectedColor = UIColor.darkGray

//MARK: - Public Interface Protocol
protocol BrowserViewInterface {
}

private let kTouchJavaScriptString: String = "document.ontouchstart=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:start:\"+x+\":\"+y;};document.ontouchmove=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:move:\"+x+\":\"+y;};document.ontouchcancel=function(event){document.location=\"myweb:touch:cancel\";};document.ontouchend=function(event){document.location=\"myweb:touch:end\";};"
//MARK: BrowserView Class
final class BrowserView: BaseUserInterface {
    @IBOutlet weak var containSearchBar: UIView!
    @IBOutlet weak var containWebView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    var defaultColor: UIColor!
    
    var webView: WKWebView = WKWebView(frame: CGRect.zero)
    var url: URL!
    let refreshControl = UIRefreshControl()
    var searchController: UISearchController!
    var googleDriverURL: String?
    var statusBarHidden: Bool = false
    private var imgURL: String = "", timer: Timer! = nil
    private var countPresentAdv: Int = UserSession.shared.countPlayVideo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchController()
        self.searchBar.textField?.leftViewMode = .never
        self.defaultColor = self.favoritesButton.tintColor
        self.backButton.image = Asset.Browser.backIcon.image
        self.forwardButton.image = Asset.Browser.forwardIcon.image
        self.favoritesButton.image = Asset.Browser.iconBrowserFavorites.image
        self.updateNavigationItem()
        self.updateFavoritesButton()
        self.url = URL(string: self.defaultURLString!)!
        self.loadURL(url)
        PurchaseManager.shared.observerUpgradeVersion {[weak self] in
            self?.removeBannerFromSupperView()
        }
        NavigationManager.shared.createAndLoadAdvertise()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        self.webView.uiDelegate = nil
        self.webView.navigationDelegate = nil
        self.webView.scrollView.delegate = nil
        if isViewLoaded {
            self.webView.removeObserver(self, forKeyPath: estimatedProgressKeyPath)
        }
    }
    
    override func setupUI() {
        //Refresh Control
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        self.progressView.alpha = 0
        self.configureWebView()
    }
    
    func updateNavigationItem() {
        self.navigationItem.title = titleLoading
        
        let historyButtonItem = UIBarButtonItem(image: Asset.Browser.iconBrowserHistory.image, style: .done, target: self, action: #selector(openHistory))
        self.navigationItem.leftBarButtonItem = historyButtonItem
        
        let favoritesButtonItem = UIBarButtonItem(image: Asset.Browser.iconBrowserFavorites.image, style: .done, target: self, action: #selector(openFavorites))
        self.navigationItem.rightBarButtonItem = favoritesButtonItem
    }
    
    func configureWebView() {
        let menuItem = UIMenuItem(title: "Save Image to Application", action: #selector(self.saveImage(sender:)))
        UIMenuController.shared.menuItems = [menuItem]
        webView.frame = self.containWebView.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.autoresizesSubviews = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsLinkPreview = true
        self.webView.scrollView.delegate = self
        webView.isMultipleTouchEnabled = true
        webView.scrollView.alwaysBounceVertical = true
        self.containWebView.addSubview(webView)
        refreshControl.addTarget(self, action: #selector(self.reload(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.addObserver(self, forKeyPath: estimatedProgressKeyPath, options: .new, context: &estimatedProgressContext)
    }
    // MARK: - Public
    public func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }
    
    public func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    public func loadURLString(_ urlString: String) {
        var urlUpdate = urlString.lowercased()
        if urlUpdate.hasPrefix("http://") || urlUpdate.hasPrefix("fpt://") || urlUpdate.hasPrefix("https://") {
        } else {
            urlUpdate = "http://\(urlString)"
        }
        if urlUpdate.validURLString(), let url = URL(string: urlUpdate) {
            webView.load(URLRequest(url: url))
        } else {
            self.showAlertWith(title: L10n.Generic.Error.Alert.title, messsage: L10n.Settings.Browser.Url.required)
        }
    }
    
    public func loadHTMLString(_ htmlString: String, baseURL: URL?) {
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
    
    func loadWebView() {
        if !url.absoluteString.isEmpty {
            loadURL(url)
        }
    }
    
    func updateToolBar() {
        forwardButton.isEnabled = webView.canGoForward;
        backButton.isEnabled = webView.canGoBack;
        if webView.isLoading {
            if let urlString = webView.url?.absoluteString {
                self.searchBar.text = urlString
            }
        }
        refreshControl.endRefreshing()
        if webView.isLoading {
            if let urlString = webView.url?.absoluteString {
                var titleString = urlString.replacingOccurrences(of: "http://", with: "", options: .literal, range: nil)
                titleString = titleString.replacingOccurrences(of: "https://", with: "", options: .literal, range: nil)
                navigationItem.title = titleString
            }
        } else {
            navigationItem.title = webView.title
        }
        self.updateFavoritesButton()
    }
    
    func autoFocusSearchBar() {
        self.searchController.isActive = true
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchBar = self.searchController.searchBar
        self.searchBar.frame.size.width = self.containSearchBar.frame.size.width
        self.searchBar.frame.size.height = self.containSearchBar.frame.size.height
        self.searchBar.placeholder = "Input URL"
        self.searchBar.delegate = self
        self.searchBar.keyboardType = .URL
        self.searchBar.returnKeyType = .go
        self.searchBar.textField?.backgroundColor = .lightGray
        self.searchBar.textField?.textAlignment = .center
        self.searchBar.barTintColor = UIColor.white
        self.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.containSearchBar.addSubview(self.searchBar)
    }
    
    func showProgressView(_ show: Bool) {
        if show {
            self.containSearchBar.bringSubviewToFront(self.progressView)
        } else {
            self.containSearchBar.bringSubviewToFront(self.searchBar)
        }
    }
    func updateFavoritesButton() {
        if let isFavorites = self.currentHistory()?.isFavorites, isFavorites == true {
            self.favoritesButton.tintColor = self.defaultColor
        } else {
            self.favoritesButton.tintColor = unSelectedColor
        }
    }
    
    func addHistory(_ history: NewsHistory) {
        let newsHistories = ModelManager.shared.fetchObjects(NewsHistory.self).sorted(byKeyPath: "dateUpdated", ascending: false).map({$0})
        if newsHistories.count > 100, let oldHistory = newsHistories.last {
            ModelManager.shared.deleteObject(oldHistory)
        }
        ModelManager.shared.addObject(history)
    }
    func currentHistory() -> NewsHistory? {
        if let urlString = webView.url?.absoluteString {
            return ModelManager.shared.fetchObject(NewsHistory.self, filter: NSPredicate(format: "papeURL == %@", urlString))
        }
        return nil
    }
    
    func showHistoryViewWithFavorites(_ favorites: Bool) {
        self.presenter.openPasscodeWithCompletionBlock {(finished) in
            if finished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {[weak self] in
                    let controller = NewsHistoryTableViewController()
                    controller.delegate = self
                    controller.showFavorites = favorites
                    let navController = UINavigationController(rootViewController: controller)
                    self?.present(navController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @objc func saveImage(sender: UIMenuItem) {
        
    }
    
    @objc func openHistory() {
        self.showHistoryViewWithFavorites(false)
    }
    
    @objc func openFavorites() {
        self.showHistoryViewWithFavorites(true)
    }
    
    @IBAction func addToFavorites(_ sender: Any) {
        if let currentHistory = self.currentHistory() {
            ModelManager.shared.updateObject {
                currentHistory.isFavorites = !currentHistory.isFavorites
            }
            self.updateFavoritesButton()
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        self.webView.stopLoading()
        self.progressView.setProgress(0, animated: true);
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.webView.goBack()
        self.searchBar.text = webView.url?.absoluteString
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        self.webView.goForward()
        self.searchBar.text = webView.url?.absoluteString
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        self.webView.reload()
        refreshControl.endRefreshing()
    }
    
    func playGoogleDriverURLString(_ url: String) {
        guard url.validURLString() else {
            return
        }
        if let videoURL = URL(string: url) {
            self.startActivityLoading()
            let task = URLSession.shared.dataTask(with: videoURL) {[unowned self] (data, reponse, error) in
                DispatchQueue.main.async {
                    self.stopActivityLoading()
                    if let response = reponse as? HTTPURLResponse,
                        let allHttpHeaders = response.allHeaderFields as? [String: String],
                        let responseUrl = response.url, let reponseData = data {
                        let htmlString = String(data: reponseData, encoding: .utf8)
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHttpHeaders, for: responseUrl)
                        for cookie in cookies {
                            HTTPCookieStorage.shared.setCookie(cookie)
                        }
                        if let html = htmlString as NSString?, html.driverHasVideoStreamming(), let urlPlayer = html.htmlGoogleDriverLink() {
                            NavigationManager.shared.handlerDismissAdvertisement = {
                                NavigationManager.shared.showVideoGoogleDriverURL(urlPlayer, cookies: HTTPCookieStorage.shared.cookies)
                            }
                            NavigationManager.shared.presentAdverstive()
                        } else {
                            self.url = videoURL
                            self.loadURL(videoURL)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func getDirectionURLString(_ url: String) {
        guard url.validURLString() else {
            return
        }
        if let videoURL = URL(string: url) {
            self.startActivityLoading()
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            
            let task = session.dataTask(with: videoURL) {[unowned self] (data, reponse, error) in
                self.stopActivityLoading()
            }
            task.resume()
        }
    }
    
    func startSearchWebView() {
        self.searchBar.textField?.textAlignment = .left
    }
    
    func endSearchWebView() {
        if let urlString = webView.url?.absoluteString {
            self.searchBar.text = urlString
        }
        self.searchBar.textField?.textAlignment = .center
    }
    
    func updateOtherViews(hidden: Bool, animated: Bool) {
        guard let tabBar = tabBarController?.tabBar else {
            return
        }
        let offset = UIScreen.main.bounds.maxY - tabBar.frame.minY
        if offset != 0 && offset != tabBar.frame.height {
            // Animating, return
            return
        }
        
        var tabBarFrame = tabBar.frame
        let bottomConstraint = view.constraints.filter({ $0.firstAttribute == .bottom && $0.secondAttribute == .bottom }).first
        let topConstraint = view.constraints.filter({ $0.firstAttribute == .top && $0.secondAttribute == .bottom }).first
        var bottomConstraintValue: CGFloat = 0
        var topConstraintValue: CGFloat = 0
        
        if hidden {
            tabBarFrame.origin.y = UIScreen.main.bounds.maxY
            bottomConstraintValue = tabBarFrame.height + self.toolBar.frame.height
            topConstraintValue = -(self.containSearchBar.frame.height + self.statusBarHeight())
        } else {
            tabBarFrame.origin.y = UIScreen.main.bounds.maxY - tabBar.frame.height
        }
        statusBarHidden = hidden
        self.setNeedsStatusBarAppearanceUpdate()
        
        let duration:TimeInterval = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, animations: {
            bottomConstraint?.constant = bottomConstraintValue
            topConstraint?.constant = topConstraintValue
            self.navigationController?.setNavigationBarHidden(hidden, animated: false)
            self.view.setNeedsLayout()
            tabBar.frame = tabBarFrame
        })
    }
    
    override func showBannerView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        containWebView.addSubview(bannerView)
        containWebView.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: containWebView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: containWebView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
}

extension BrowserView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            self.updateOtherViews(hidden: true, animated: true)
            if self.bannerView == nil {
                self.showBanner()
            } else {
                self.removeBannerFromSupperView()
                self.showBannerView(self.bannerView!)
            }
        } else {
            self.updateOtherViews(hidden: false, animated: true)
            self.removeBannerFromSupperView()
        }
    }
}

extension BrowserView: URLSessionDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        DispatchQueue.main.async {
            self.stopActivityLoading()
            if let allHttpHeaders = response.allHeaderFields as? [String: String],
                let responseUrlString = allHttpHeaders["Location"] {
                if let _ = responseUrlString.range(of: "url=") {
                    self.getDirectionURLString(responseUrlString)
                } else {
                    NavigationManager.shared.showMediaPlayerURL(responseUrlString)
                }
            } else if let responseUrl = response.url {
                self.loadURLString(responseUrl.absoluteString)
            }
        }
    }
    
}
extension BrowserView: NewsHistoryTableViewControllerDelegate {
    func didSelectHistory(_ history: NewsHistory) {
        self.url = URL(string: history.papeURL)!
        self.loadURL(url)
    }
}

extension BrowserView {
    // MARK: - Observer
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, (keyPath == estimatedProgressKeyPath && context == &estimatedProgressContext) {
            progressView.alpha = 1
            self.showProgressView(true)
            let animated = webView.estimatedProgress > Double(progressView.progress)
            progressView.setProgress(Float(webView.estimatedProgress), animated: animated)
            if webView.estimatedProgress >= 1 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                    self.showProgressView(false)
                }, completion: { (finished) in
                    self.progressView.progress = 0
                    self.showProgressView(false)
                })
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension BrowserView: UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.startSearchWebView()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.loadURLString(self.searchBar.text!)
        self.searchController.isActive = false
        if let urlString = webView.url?.absoluteString {
            self.searchBar.text = urlString
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.endSearchWebView()
        })
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.textField?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CellIdentifier"
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension BrowserView: WKNavigationDelegate {
    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.updateToolBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    if error == nil, let html = html as? NSString {
                                        if html.driverHasVideoStreamming(), let urlPlayer = html.htmlGoogleDriverLink() {
                                            NavigationManager.shared.handlerDismissAdvertisement = {
                                                NavigationManager.shared.showVideoGoogleDriverURL(urlPlayer, cookies: HTTPCookieStorage.shared.cookies)
                                            }
                                            NavigationManager.shared.presentAdverstive()
                                        }
                                    }
        })
        webView.evaluateJavaScript(kTouchJavaScriptString, completionHandler: nil)
        self.updateToolBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let urlString = webView.url?.absoluteString {
            if let currentHistory = self.currentHistory() {
                ModelManager.shared.updateObject {
                    [unowned self] in
                    currentHistory.dateUpdated = Date()
                    currentHistory.name = self.navigationItem.title ?? ""
                }
            } else {
                let currentHistory = NewsHistory()
                currentHistory.name = self.navigationItem.title ?? ""
                currentHistory.papeURL = urlString
                self.addHistory(currentHistory)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateToolBar()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.updateToolBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestString: String = navigationAction.request.url?.absoluteString
        {
            if (requestString == "about:blank") {
                decisionHandler(.cancel)
                return
            }
            var components: [String] = requestString.components(separatedBy: ":")
            if (components.count > 1 && components[0] == "myweb") {
                if (components[1] == "touch") {
                    for subView in self.webView.scrollView.subviews {
                        for recogniser in subView.gestureRecognizers ?? [] {
                            if recogniser is UILongPressGestureRecognizer {
                                subView.removeGestureRecognizer(recogniser)
                            }
                        }
                    }
                    if (components[2] == "start") {
                        let ptX: Float = Float(components[3])!
                        let ptY: Float = Float(components[4])!
                        let js: String = "document.elementFromPoint(\(ptX), \(ptY)).tagName"
                        webView.evaluateJavaScript(js,
                                                   completionHandler: {[weak self] (tagName: Any?, error: Error?) in
                                                    if error == nil, let tagName = tagName as? String {
                                                        self?.imgURL = ""
                                                        if (tagName == "IMG") {
                                                            webView.evaluateJavaScript("document.elementFromPoint(\(ptX), \(ptY)).src",
                                                                                       completionHandler: {(imgURL: Any?, error: Error?) in
                                                                                        guard let self = self else { return }
                                                                                        if error == nil, let imgURL = imgURL as? String {
                                                                                            self.imgURL = imgURL
                                                                                            self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.handleLongTouch), userInfo: nil, repeats: false)
                                                                                        }
                                                                }
                                                            )
                                                        }
                                                    }
                        })
                    } else {
                        if (components[2] == "move") {
                        } else {
                            if (components[2] == "end") {
                                self.timer?.invalidate()
                                self.timer = nil
                            }
                        }
                    }
                }
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse,
            let allHttpHeaders = response.allHeaderFields as? [String: String],
            let responseUrl = response.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHttpHeaders, for: responseUrl)
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        debugPrint("web direct url:\(webView.url?.absoluteString ?? "")")
    }
    
    @objc func handleLongTouch() {
        self.showActionWith(title: "Save Image", message: nil, cancelTitle: L10n.Generic.Button.Title.cancel, cancelBlock: nil, actionTitle: L10n.Generic.save, actionBlock: { [weak self] _ in
            self?.saveImage()
        })
    }
    
    func saveImage () {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {[unowned self] in
            do {
                let url = URL(string: self.imgURL)!
                let data = try Data(contentsOf: url)
                if let originImage = UIImage(data: data), let jpgData = originImage.jpegData(compressionQuality: 0.5) {
                    let saveableImage = UIImage(data: jpgData)
                    // Save to album
                    let fileName = "\(DocumentManager.shared.fileNameNoExtension).jpeg"
                    let media = Media(image: saveableImage!, caption: fileName)
                    self.presenter.saveMedia(media: media)
                }
            }
            catch let error {
                Logger.debug("Failed save image with error:\(error.localizedDescription)")
                return
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil {
            Logger.debug("Failed save image with error:\(error?.localizedDescription ?? "")")
            return
        }
        Logger.debug("Save image success")
    }
    
}

extension BrowserView: WKUIDelegate {
    // MARK: - WKUIDelegate
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            debugPrint(url.absoluteString)
            var urlString = url.absoluteString
            if let _ = urlString.range(of: "appmoviehd.info/link", options: .caseInsensitive), let index = urlString.index(of: "=") {
                let cipherString = urlString[urlString.index(after: index)..<urlString.endIndex]
                if let decryptedString = (cipherString as NSString).decryptAES() {
                    urlString = decryptedString
                }
            }
            if let escapedString = urlString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
                //do something with escaped string
                urlString = escapedString
            }
            
            if let _ = urlString.range(of: "drive.google.com") {
                self.googleDriverURL = urlString
                self.playGoogleDriverURLString(urlString)
            } else if let _ = urlString.range(of: "appmoviehd.info/redirection") {
                //                self.loadURLString(urlString)
                self.getDirectionURLString(urlString)
            }  else {
                NavigationManager.shared.showMediaPlayerURL(urlString)
            }
        }
        
        if let mainFrame = navigationAction.targetFrame?.isMainFrame, mainFrame == false {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: "Hey, listen!", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Swift.Void) {
        let ac = UIAlertController(title: "Hey, listen!", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
        completionHandler(true)
    }
}

//MARK: - Public interface
extension BrowserView: BrowserViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension BrowserView {
    var presenter: BrowserPresenter {
        return _presenter as! BrowserPresenter
    }
    var displayData: BrowserDisplayData {
        return _displayData as! BrowserDisplayData
    }
}
