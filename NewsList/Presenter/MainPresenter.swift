//
//  MainPresenter.swift
//  NewsList
//
//  Created by lampa on 5/25/18.
//  Copyright © 2018 lampa. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()


class MainPresenter{
    var dataFromUrl = Set<ViewData>()
    var delegate: ViewControllerDelegate?
    
    
    func getAllData() -> Set<ViewData> {
        return dataFromUrl
    }
    
    
    func getCount() ->Int{
        return dataFromUrl.count
    }
    
    
    func cellConfig( indexPath:Int,cell:MyTableViewCell)  {
        
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            let cellData = self.dataFromUrl[self.dataFromUrl.index(self.dataFromUrl.startIndex, offsetBy: indexPath)]
            
            let url = cellData.image_url
            
            let urlImage:URL = URL(string: url)!
            cell.imageViewItem.sd_setImage(with: urlImage)
            cell.viewsCountLabel.text = cellData.view_count
            cell.titleLabel.text = cellData.name
            
        } else {
            print("Internet connection FAILED")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    
    func getJsonFromURL(page:Int){
        let myURLAdr = "https://api.themoviedb.org/3/movie/popular?api_key=f910e2224b142497cc05444043cc8aa4&language=en-US&page="+String(page)
        let url = NSURL(string: myURLAdr)
        
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let resArray = jsonObj!.value(forKey: "results") as? NSArray {
                    
                    for item in resArray{
                        
                        if let itemDict = item as? NSDictionary {
                            
                            var name = "",price = "",view_count = "",owner = "",image_url = ""
                            
                            if let pName = itemDict.value(forKey: "title") as? String {
                                name = pName
                            }
                            if let pView_count = itemDict.value(forKey: "vote_count") as? Int {
                                view_count = "Votes: " + String(pView_count)
                            }
                            if let pImage = itemDict.value(forKey: "backdrop_path") as? String {
                                image_url = "https://image.tmdb.org/t/p/w500"+pImage
                            }else{
                                image_url = "https://pbs.twimg.com/profile_images/789117657714831361/zGfknUu8_400x400.jpg"
                            }
                            
                            
                            self.dataFromUrl.insert(ViewData(name: name, price: price, view_count: view_count, owner: owner, image_url: image_url))    
                        }
                    }
                }
                
                OperationQueue.main.addOperation({
                    //calling another function after fetching the json
                    self.delegate?.createTopNews(topNews: self.dataFromUrl)
                    print("CreateTopNews")
                    self.delegate?.reloadData()
                })
            }
        }).resume()
    }
    
    
}

protocol ViewControllerDelegate {
    func reloadData()
    func createTopNews(topNews:Set<ViewData>)
    func reloadTableRow(index:Int)
}


