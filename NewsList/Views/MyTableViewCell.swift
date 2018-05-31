//
//  MyTableViewCell.swift
//  NewsList
//
//  Created by lampa on 5/31/18.
//  Copyright © 2018 lampa. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewItem: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    let sepHeight: CGFloat = 7.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        resetContent()
        
        let screenSize = UIScreen.main.bounds
        let additionalSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-2-sepHeight, width: screenSize.width, height: 1))
        additionalSeparator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.addSubview(additionalSeparator)
        
        
        let separatorHeight = sepHeight
        let additionalSeparator2 = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height-separatorHeight, width: screenSize.width, height: separatorHeight))
        additionalSeparator2.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)
        self.addSubview(additionalSeparator2)
        
    }
    
    override func prepareForReuse() {
        resetContent()
    }
    
    func resetContent() {
        imageViewItem.image = nil
        titleLabel.text = nil
        viewsCountLabel.text = nil
    }
    
}
