//
//  FeedViewController.swift
//  exchangeAGram
//
//  Created by Kyle Raley on 5/7/15.
//  Copyright (c) 2015 Kyle Raley. All rights reserved.
//

import UIKit
import MobileCoreServices //import in build phase in main project (Importing framework)
import CoreData //use of core data
import MapKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    var feedArray:[AnyObject] = [] //Creating array to hold the feed items
    
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setting up location stuff
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //most precise location possible
        locationManager.requestAlwaysAuthorization() //request permission to use location services
        
        
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //creating fetch request manually
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        feedArray = context.executeFetchRequest(request, error: nil)!
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MapViewButtonTapped(sender: UIBarButtonItem) { //moves to map VC
        performSegueWithIdentifier("mapSegue", sender: nil)
    
    }
    
    //Camera button
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        //check to see if camera is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var cameraController = UIImagePickerController()
            cameraController.delegate = self //need to conform to protocalls above
            
            //Source type we will be using (which is the camera)
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            
            cameraController.allowsEditing = false
            
            //present on screen
            self.presentViewController(cameraController, animated: true, completion: nil)
        }else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            
            var photoLibraryController = UIImagePickerController()
            //set the delegate property
            photoLibraryController.delegate = self
            //source type
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            
            photoLibraryController.mediaTypes = mediaTypes
            
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
            
            
            println("No camera detected")
        }else{
            //Alert message on screen
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo Library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    
    //UICOllectionViewDataSource
    //Need these functions to conform to protocall
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count //what gets returned determins number of cells to create
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCell //"cell is defined in storyboard
        
        let thisitem = feedArray[indexPath.row] as! FeedItem
        
        cell.imageView.image = UIImage(data: thisitem.image)
        cell.captionLabel.text = thisitem.caption
        
        return cell
    }
    
    //UICollectionViewDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage //dictionary that grabs the original image and set it as a UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0) //turns UIImage type back as Jpeg image or a data type
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1) //Can change to different qualities of the images.
        
        let managedOjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        //entity description
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedOjectContext!)
        
        //creating a feed Item
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedOjectContext!)
        
        //saving feed item
        feedItem.image = imageData
        feedItem.caption = "Text Caption"
        feedItem.thumbnail = thumbNailData //setting thumbnail image to the representation of the actual
        feedItem.latitude = locationManager.location.coordinate.latitude
        feedItem.longitude = locationManager.location.coordinate.longitude
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
        feedArray.append(feedItem)
        println("UICollection View Delegate")
        self.dismissViewControllerAnimated(true, completion: nil) // allows to see feed view controller again
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        var filterVC = FilterViewController()//create instance
        filterVC.thisFeedItem = thisItem //setting property defined in FilterVC.swift
        
        self.navigationController?.pushViewController(filterVC, animated: false) //presents filter VC on screen
        
    }
    
    //CLLocation Manager delegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Locations = \(locations)")
    }
    

}
