//
//  Data.swift
//  NewsList
//
//  Created by lampa on 5/25/18.
//  Copyright © 2018 lampa. All rights reserved.
//
import UIKit

class ViewData: Equatable, Hashable  {
    var name,price,view_count,owner,image_url: String
    
    init(name:String,price:String,view_count:String,owner:String,image_url:String) {
        self.name = name
        self.price = price
        self.view_count = view_count
        self.owner = owner
        self.image_url = image_url
        
    }
    
    func testPrint(){
        print(name, price,view_count,owner,image_url, separator: " ", terminator: "\n")
    }
    
    func getVotes() -> Int {
        let arr = view_count.split(separator: " ")
        let res = (arr.last! as NSString).integerValue
        return res
    }
    
    var hashValue: Int {
        get {
            return name.hashValue << 15 
        }
    }
}
func ==(lhs: ViewData, rhs: ViewData) -> Bool {
    return lhs.name == rhs.name && lhs.price == rhs.price
}
