//
//  FilterCell.swift
//  exchangeAGram
//
//  Created by Kyle Raley on 5/29/15.
//  Copyright (c) 2015 Kyle Raley. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    //Need custom initializer to immediantley create view
    
    override init(frame: CGRect) {
        super.init(frame: frame) //gets functionality of the whole frame while allowing to do more stuff
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))//setting up the image view to expand the entire screen
        
        contentView.addSubview(imageView) //add image view to the content view
        
    }
    
    //making compliant and provided by apple
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
