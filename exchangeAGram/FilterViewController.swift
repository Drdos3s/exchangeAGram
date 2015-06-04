//
//  FilterViewController.swift
//  exchangeAGram
//
//  Created by Kyle Raley on 5/28/15.
//  Copyright (c) 2015 Kyle Raley. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context:CIContext = CIContext(options: nil)
    
    var filters:[CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()//returns path of temp directory -- will automatically clear itself
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //set background property and add subview to show VC
        collectionView.backgroundColor = UIColor.whiteColor()
        
        //allow to use the filtercell class
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UICollectionViewDataSource
    //Necessary to conform to collection view protocalls
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FilterCell
        
        cell.imageView.image = placeHolderImage
        
        //create a new queue for filters
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getChachedImage(indexPath.row)
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                cell.imageView.image = filterImage
            })
        })
        
        //cell.imageView.image = filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row]) -- NOt needed any more because code above runs the same thing on background thread
        
        return cell
    }
    
    //UIcollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        
        self.thisFeedItem.image = imageData
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbnail = thumbNailData
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    //Helper Function
    
    func photoFilters () -> [CIFilter] {
        //set filters provided by apple
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        //set filters that require a bit of customization
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "InputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        //read in data
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)//apply filter and recieve output image
        let filteredImage:CIImage = filter.outputImage
        
        //getting back an optimized image so it doesnt break your shit
        let extent = filteredImage.extent()
        let cgImage:CGImage = context.createCGImage(filteredImage, fromRect: extent)
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    //caching functions
    func cacheImage(imageNumber: Int) {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName){//check to see if file exists at file path
            let data = self.thisFeedItem.thumbnail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getChachedImage (imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath){
            image = UIImage(contentsOfFile: uniquePath)!
        }else{
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
    }
}
