//
//  FeedItem.swift
//  exchangeAGram
//
//  Created by Kyle Raley on 5/29/15.
//  Copyright (c) 2015 Kyle Raley. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbnail: NSData //new property to store a thumbnail
    
}
