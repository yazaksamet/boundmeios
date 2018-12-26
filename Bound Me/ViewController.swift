//
//  ViewController.swift
//  Bound Me
//
//  Created by Samet Yazak on 24/12/2018.
//  Copyright © 2018 Samet Yazak. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var lastSendTime : TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("start")
        
        determineMyCurrentLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineMyCurrentLocation() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            
            // Set an accuracy level. The higher, the better for energy.
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            
            // Enable automatic pausing
            locationManager.pausesLocationUpdatesAutomatically = true;
            
            // Specify the type of activity your app is currently performing
            locationManager.activityType = CLActivityType.fitness;
            
            // Enable background location updates
            locationManager.allowsBackgroundLocationUpdates = true;
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let tStamp = Date().timeIntervalSince1970
        if (tStamp - lastSendTime > 120) {
            lastSendTime = tStamp
            sendPhoneInformation(latitude:userLocation.coordinate.latitude, longitude:userLocation.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    @IBAction func sendPhoneInfo(button: AnyObject) {
        print("button clicked")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        sendPhoneInformation(latitude: 100, longitude: 100)
    }
    
    func sendPhoneInformation(latitude: Double, longitude: Double) {
        let parameters = ["userId": "5c1ffd62e562f70017a66a0b", "latitude": "\(latitude)", "longitude": "\(longitude)", "batteryPercentage": "35"]
        
        //create the url with URL
        let url = URL(string: "https://boundme.herokuapp.com/api/mobile")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

