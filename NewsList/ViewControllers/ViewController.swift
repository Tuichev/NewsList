//
//  ViewController.swift
//  search & top >8000
//
//  Created by lampa on 5/25/18.
//  Copyright © 2018 lampa. All rights reserved.
//

import UIKit

//Dirty

class ViewController: UIViewController, ViewControllerDelegate{
    
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var leadingConsSideMenu: NSLayoutConstraint!
    
    
    var topNews:Set<ViewData>?
    var filteredData = [ViewData]()
    var presenter:MainPresenter?
    var button:UIButton?
    var buttonSearch:UIButton?
    var searchBar:UISearchBar?
    var titleLabel: UILabel?
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var timer:Timer!
    var updateCounter:Int!
    var inSearchMode = false
    var menuShowing = false
    var imageCount = 0
    var currentPage:Int!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(ViewController.handleRefresh(_:)),for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.blue
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPage=1
        presenter = MainPresenter()
        presenter?.delegate = self
        presenter?.getJsonFromURL(page: currentPage)
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self,
                                     selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        updateCounter=0
        
        scrollView.delegate = self
        
        UITabBarItem.appearance()
            .setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 14)!,NSAttributedStringKey.foregroundColor:UIColor.white],for: .normal)
        
        
        let itemFrame = (tabBar.items?[0].value(forKey: "view")as? UIView)?.frame
        let tabCount = CGFloat((tabBar.items?.count)!)
        let tabItemWidth = navBarView.frame.width / tabCount
        
        UITabBar.appearance().selectionIndicatorImage = getImageWithColorPosition(color: UIColor.white, size: CGSize(width:tabItemWidth,height: (itemFrame?.height)!), lineSize: CGSize(width:(tabItemWidth), height:2))
        
        tabBar.selectedItem = tabBar.items?.first
        
        createSettButton()
        addLabelToNavBar()
        createSearchBar()
        setupSideMenu()
        
        self.tableView.addSubview(self.refreshControl)
        self.tableView.allowsSelection = false
        self.tableView.register(UINib (nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    func getImageWithColorPosition(color: UIColor, size: CGSize, lineSize: CGSize) -> UIImage {
        let rect = CGRect(x:0, y: 0, width: size.width, height: size.height)
        let rectLine = CGRect(x:0, y:size.height-lineSize.height,width: lineSize.width,height: lineSize.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.setFill()
        UIRectFill(rect)
        color.setFill()
        UIRectFill(rectLine)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func createSearchBar()
    {
        buttonSearch = UIButton.init(type: .system)
        buttonSearch?.frame = CGRect(x: self.view.frame.width-50, y: navBarView.frame.height-40, width: 30, height: 30)
        buttonSearch?.setImage( UIImage(named: "searchIco"), for: .normal)
        buttonSearch?.imageView?.contentMode = .scaleAspectFit
        buttonSearch?.addTarget(self, action: #selector(buttonSearchClicked(_:)), for: .touchUpInside)
        navBarView.addSubview(buttonSearch!)
        
        let x = (titleLabel?.frame.maxX) ?? 150
        let frame = CGRect(x: x, y: navBarView.frame.height-40, width: self.view.frame.width-x, height: 40)
        
        searchBar = UISearchBar()
        searchBar?.showsCancelButton = true
        searchBar?.placeholder = "Enter name of film"
        searchBar?.sizeToFit()
        searchBar?.searchBarStyle = .minimal
        searchBar?.frame = frame
        searchBar?.returnKeyType = UIReturnKeyType.done
        searchBar?.delegate = self
        
        
        let textFieldInsideSearchBar = searchBar?.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        searchBar?.frame.origin.x+=(searchBar?.frame.width) ?? 500
        navBarView.addSubview(searchBar!)
    }
    
    
    
    func createSettButton()
    {
        button = UIButton.init(type: .system)
        button?.frame = CGRect(x: 20, y: navBarView.frame.height-40, width: 20, height: 30)
        button?.setImage( UIImage(named: "sideMenuBtn"), for: .normal)
        button?.imageView?.contentMode = .scaleAspectFit
        button?.addTarget(self, action: #selector(buttonSettClicked(_:)), for: .touchUpInside)
        navBarView.addSubview(button!)
        
    }
    
    func setupSideMenu()
    {
        sideMenuView.layer.shadowOpacity=1
        sideMenuView.layer.shadowRadius = 6
    }
    
    func addLabelToNavBar()
    {
        titleLabel = UILabel(frame: CGRect(x:(button?.frame.maxX)!,y: (button?.frame.minY)!, width: navBarView.frame.size.width*0.3,height: (button?.frame.height)!))
        titleLabel?.textAlignment = NSTextAlignment.center
        titleLabel?.text = "News"
        titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        titleLabel?.textColor = UIColor.white
        
        navBarView.addSubview(titleLabel!)
    }
    
    func reloadTableRow(index:Int)
    {
        let indexPath = IndexPath(item: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .top)
    }
    
    func reloadData()
    {
        print("reloadData")
        tableView.reloadData()
    }
    
    func constrLastView(labelFir:UILabel,imageView:UIImageView?, labelSec:UILabel?)
    {
        let horizonalContraints = NSLayoutConstraint(item: labelFir, attribute:
            .leadingMargin, relatedBy: .equal, toItem: labelSec,
                            attribute: .trailing, multiplier: 1.0,
                            constant: 10)
        
        var pinBottom:NSLayoutConstraint?
        
        labelFir.translatesAutoresizingMaskIntoConstraints=false
        
        pinBottom = NSLayoutConstraint(item: labelFir, attribute: .bottom, relatedBy: .equal,
                                       toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: -40)
        
        NSLayoutConstraint.activate([horizonalContraints, pinBottom!])
    }
    
    func constrLabels(labelFir:UILabel,imageView:UIImageView?, labelSec:UILabel?)
    {
        let horizonalContraints = NSLayoutConstraint(item: labelFir, attribute:
            .leadingMargin, relatedBy: .equal, toItem: imageView,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 15)
        
        var pinBottom:NSLayoutConstraint?
        
        labelFir.translatesAutoresizingMaskIntoConstraints=false
        
        if (labelSec==nil)
        {
            pinBottom = NSLayoutConstraint(item: labelFir, attribute: .bottom, relatedBy: .equal,
                                           toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: -40)
            
        }
        else
        {
            pinBottom = NSLayoutConstraint(item: labelFir, attribute: .bottom, relatedBy: .equal,toItem: labelSec, attribute: .top, multiplier: 1.0, constant: -20)
        }
        NSLayoutConstraint.activate([horizonalContraints, pinBottom!])
    }
    
    func createTopNews(topNews:Set<ViewData>)
    {
        topView.layer.cornerRadius = 15
        topView.layer.masksToBounds = true
        
        let News = topNews.filter({ $0.getVotes() > 8000 })
        
        imageCount = News.count
        
        if imageCount>6{
            imageCount = 6
        }
        
        pageControl.numberOfPages = imageCount
        var i = 0
        
        
        for image in News{
            frame.origin.x = (self.view.frame.width)*CGFloat(i)
            frame.size = scrollView.frame.size
            frame.size.width = self.view.frame.width
            
            let imageView = UIImageView(frame: frame)
            let URL_IMAGE:URL = URL(string: image.image_url)!
            imageView.sd_setImage(with: URL_IMAGE)
            
            let overlay:UIView = UIView(frame: CGRect(x:0,y: 0, width:imageView.frame.size.width, height:imageView.frame.size.height))
            overlay.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.4)
            imageView.addSubview(overlay)
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width:self.view.frame.width-20, height: 70))
            label.textAlignment = .left
            label.textColor = UIColor.white
            
            label.font = UIFont(name:"HelveticaNeue-Bold", size: 26.0)
            label.text = image.name
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 3
            imageView.addSubview(label)
            
            
            let labelDesc = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/3, height: 30))
            imageView.addSubview(labelDesc)
            
            let labelLastView = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/3, height: 30))
            imageView.addSubview(labelLastView)
            
            labelLastView.textAlignment = .left
            labelLastView.textColor = #colorLiteral(red: 0.5529411765, green: 0.5529411765, blue: 0.5529411765, alpha: 1)
            labelLastView.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
            labelLastView.text = "- 2 hours ago"
            
            
            labelDesc.textAlignment = .left
            labelDesc.textColor = #colorLiteral(red: 0, green: 0.6431372549, blue: 0.9294117647, alpha: 1)
            labelDesc.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
            labelDesc.text = image.view_count
            
            constrLabels( labelFir: labelDesc, imageView: imageView,labelSec: nil)
            constrLabels( labelFir: label, imageView: imageView,labelSec: labelDesc)
            constrLastView(labelFir:labelLastView,imageView: imageView, labelSec: labelDesc )
            
            
            
            scrollView.addSubview(imageView)
            i = i+1
            
        }
        
        scrollView.contentSize = CGSize(width: (self.view.frame.width)*CGFloat(imageCount), height: scrollView.frame.size.height)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        presenter?.getJsonFromURL(page: 1)
        // self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @objc func buttonSearchClicked(_:UIButton)
    {
        UIView.animate(withDuration: 1.0, animations: {
            self.searchBar?.frame.origin.x-=self.searchBar?.frame.width ?? 500
            self.buttonSearch?.frame.origin.x+=(self.buttonSearch?.frame.width ?? 200)+60
        }, completion: {
            (value: Bool) in
            //do nothing after animation
        })
    }
    
    @objc func buttonSettClicked(_:UIButton)
    {
        if menuShowing
        {
            leadingConsSideMenu.constant = -140
        }
        else{
            leadingConsSideMenu.constant = 0
            
        }
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        menuShowing = !menuShowing
    }
    
    @objc internal func updateTimer()
    {
        if(updateCounter<imageCount)
        {
            pageControl.currentPage=updateCounter
            let offsetX:CGFloat = self.view.frame.width  * CGFloat(updateCounter)
            scrollView.setContentOffset(CGPoint(x:offsetX,y:CGFloat(0.0)), animated: true)
            updateCounter = updateCounter+1
        }
        else{
            updateCounter=0
        }
    }
}



extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 325
    }
    
}

extension ViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredData.count
            
        }
        
        return presenter?.getCount() ?? 0
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row==((presenter?.getCount() ?? 0))-1)
        {
            moreData()
        }
    }
    
    func moreData()
    {
        currentPage=currentPage+1
        presenter?.getJsonFromURL(page: currentPage)
        
        // tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTableViewCell
        
        if inSearchMode {
            
            if let urlImage: URL = URL(string: filteredData[indexPath.row].image_url) {
                cell.imageViewItem.sd_setImage(with: urlImage)
            }
            
            cell.viewsCountLabel.text = filteredData[indexPath.row].view_count
            cell.titleLabel.text = filteredData[indexPath.row].name
        } else {
            presenter?.cellConfig(indexPath: indexPath.row, cell: cell)
        }
        
        return cell
    }
    
}

extension ViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGFloat(scrollView.frame.size.width))
        updateCounter = pageControl.currentPage
    }
}

extension ViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            inSearchMode = true
            filteredData = (presenter?.getAllData().filter({$0.name.lowercased().contains(searchBar.text!.lowercased())}))!
            tableView.clearsContextBeforeDrawing = true
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        searchBar.text = ""
        
        UIView.animate(withDuration: 1.0, animations: {
            self.searchBar?.frame.origin.x+=self.searchBar?.frame.width ?? 500
            self.buttonSearch?.frame.origin.x-=(self.buttonSearch?.frame.width ?? 200)+60
            self.inSearchMode = false
            self.tableView.reloadData()
        }, completion: {
            (value: Bool) in
            //do nothing after animation
        })
    }
}
