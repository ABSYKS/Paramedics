/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{
    
    var manager = CLLocationManager()
    
    @IBOutlet var map: MKMapView!
    @IBOutlet weak var threatLevel: UILabel!
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var bloodtype: UILabel!
    @IBOutlet weak var existingConditions: UILabel!
    @IBOutlet weak var symptoms: UILabel!
    var timer = NSTimer()
    
    func runit(){
    timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(UIViewController.viewDidLoad), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let query = PFQuery(className: "Mediccal")
        query.getFirstObjectInBackgroundWithBlock({ (object: PFObject?, error: NSError? ) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else  {
                
                print(object)
                self.bloodtype.text = "\(object!.objectForKey("BloodType"))"
                self.existingConditions.text = "\(object!.objectForKey("ExistConditions"))"
                let first = "\(object!.objectForKey("FirstName") as! String)"
                let last = "\(object!.objectForKey("LastName") as! String)"
                self.patientName.text = first + " " + last
                let latitude = object!.objectForKey("Latitude") as! Double
                let longitude = object!.objectForKey("Longitude") as! Double
                let patientLocation = CLLocationCoordinate2DMake(latitude, longitude)
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = patientLocation
                dropPin.title = "\(first + " " + last)"
                self.map.addAnnotation(dropPin)
            }
        })
        
            if((symptoms.text?.containsString("cardiac arrest")) == true){
            threatLevel.text = "0.97"
            threatLevel.textColor = UIColor.redColor()
        }

        self.manager.delegate = self
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 8.0, *) {
            manager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        manager.startUpdatingLocation()
    }
    
    //NOTE: [AnyObject] changed to [CLLocation]
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        //userLocation - there is no need for casting, because we are now using CLLocation object
        let userLocation:CLLocation = locations[0]
        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
        let longitude:CLLocationDegrees = userLocation.coordinate.longitude
        let latDelta:CLLocationDegrees = 0.001
        let lonDelta:CLLocationDegrees = 0.001
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
