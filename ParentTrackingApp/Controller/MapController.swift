//
//  MapController.swift
//  ParentTrackingApp
//
//  Created by ahmed mostafa on 9/4/20.
//  Copyright © 2020 ahmed mostafa. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation
import UserNotifications


class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let manager = CLLocationManager()
    let db = Firestore.firestore()
    var childLatt = Double()
    var childLonn = Double()
    var childLattSec = Double()
    var childLonnSec = Double()
    var parentLatt = Double()
    var parentLonn = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lat = manager.location?.coordinate.latitude
        let lon = manager.location?.coordinate.longitude
        
        db.collection("Parent").document("Parent").setData([
            "lat":lat!
            , "lon":lon!]
            , merge: true)
        
        
        let circularRegion = CLCircularRegion.init(center: (manager.location?.coordinate)!,radius: 100.0, identifier: "Home")
        circularRegion.notifyOnEntry = true
        circularRegion.notifyOnExit = true
        manager.startMonitoring(for: circularRegion)
       
        queryChildLocation()
        queryParentLocation()
        queryChildLocationSecond()
        addAnnotaions()
        getDistanceParentToChild()
    }
    
   
    func queryChildLocation() {
        
        let childquery = db.collection("child").whereField("provider", isEqualTo: "Firebase")
        childquery.getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }else {
                for doc in snapshot!.documents  {
                    let fetchData = doc.data()
                    guard let childLat = fetchData["lat"] as? Double else {return}
                    guard let childLon = fetchData["lon"] as? Double else {return}
                    self.childLatt = childLat
                    self.childLonn = childLon
                }
            }
        }
    }
    
    func queryChildLocationSecond() {
           
           let childquery = db.collection("child2").whereField("provider", isEqualTo: "Firebase")
           childquery.getDocuments { (snapshot, err) in
               if let err = err {
                   print(err.localizedDescription)
               }else {
                   for doc in snapshot!.documents  {
                       let fetchData = doc.data()
                       guard let childLat = fetchData["lat"] as? Double else {return}
                       guard let childLon = fetchData["lon"] as? Double else {return}
                       self.childLattSec = childLat
                       self.childLonnSec = childLon
                   }
               }
           }
       }
    
    func queryParentLocation() {
        
        let parentquery = db.collection("Parent").whereField("provider", isEqualTo: "Firebase")
        parentquery.getDocuments { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            }else {
                for doc in snapshot!.documents  {
                    let fetchData = doc.data()
                    guard let parentLat = fetchData["lat"] as? Double else {return}
                    guard let parentLon = fetchData["lon"] as? Double else {return}
                    self.parentLatt = parentLat
                    self.parentLonn = parentLon
                }
            }
        }
    }
    
    
    func addAnnotaions () {
        
        let parentAnno = MKPointAnnotation()
        parentAnno.coordinate.latitude = parentLatt
        parentAnno.coordinate.longitude = parentLonn
        parentAnno.title = "MY LOCATON"
        
        let childAnno = MKPointAnnotation()
        childAnno.coordinate.latitude = childLatt
        childAnno.coordinate.longitude = childLonn
        childAnno.title = "MY 1st CHILD LOCATION"
        
        let childSecAnno = MKPointAnnotation()
        childSecAnno.coordinate.latitude = childLattSec
        childSecAnno.coordinate.longitude = childLonnSec
        childSecAnno.title = "MY 2nd CHILDLOCATION"
        
        let parentChildAnno = [parentAnno, childAnno, childSecAnno] as [MKAnnotation]
        mapView.addAnnotations(parentChildAnno)
        for annotaion in mapView.annotations {
            if annotaion.isKind(of: MKPointAnnotation.self){
                mapView.removeAnnotation(annotaion)
            }
        }
        mapView.addAnnotations(parentChildAnno)
        mapView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
    func getDistanceParentToChild () {
        
        let childLocation = CLLocation(latitude: childLatt as CLLocationDegrees, longitude: childLonn as CLLocationDegrees)
        let parentLocation = CLLocation(latitude: parentLatt as CLLocationDegrees, longitude: parentLonn as CLLocationDegrees)
        let distance = parentLocation.distance(from: childLocation)
        let roundedDistance = round(distance * 100) / 100
        print("distanc from ur 1st child is \(roundedDistance)m ")
        
        
        
        let childLocationSec = CLLocation(latitude: childLattSec as CLLocationDegrees, longitude: childLonnSec as CLLocationDegrees)
        let parentLocationSec = CLLocation(latitude: parentLatt as CLLocationDegrees, longitude: parentLonn as CLLocationDegrees)
        
        let distanceSec = parentLocationSec.distance(from: childLocationSec)
        let roundedDistanceSec = round(distanceSec * 100) / 100
        print("distanc from ur 2nd child is \(roundedDistanceSec)m ")
        
        if roundedDistance == roundedDistance {
            if roundedDistance > 200  {
                fireNotification(notificationText: "Your child exit the safe area")
            }else if roundedDistance < 200 {
                fireNotification(notificationText: "Your child is in the safe area")
            }
        }
        if roundedDistanceSec == roundedDistanceSec {
            if roundedDistanceSec > 200 {
                fireNotification(notificationText: "Your child exit the safe area")
            }else if roundedDistanceSec < 200 {
                fireNotification(notificationText: "Your child is in the safe area")
            }

        }
        
        
        
            }
    
    
    func fireNotification(notificationText: String) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Alert"
        content.body = notificationText
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "Test", content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
}




