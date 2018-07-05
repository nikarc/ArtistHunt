//
//  TrackDetailViewController.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/2/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class TrackDetailViewController: UIViewController {
    
    var track: JSON?
    let regionRadius: CLLocationDistance = 800
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueInfo: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("EVENT: \(track!["event"])")
        if let track = track {
            self.title = track["name"].stringValue
            
            let venue = track["event"]["venue"]
            let lat = venue["location"]["lat"].doubleValue
            let lon = venue["location"]["lon"].doubleValue
            
            let initialLocation = CLLocation(latitude: lat, longitude: lon)
            centerMapOnLocation(location: initialLocation)
            
            let venueName = venue["name"].stringValue
            venueNameLabel.text = venueName
            
            var venueInfoText = "\(venue["address"]) \(venue["extended_address"])\n"
            
            let performers = track["event"]["performers"].arrayValue
            performers.forEach { (performer) in
                venueInfoText += "\n\(performer["name"])"
            }
            
            venueInfo.text = venueInfoText
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func purchaseTickets(_ sender: Any) {
        if let track = track, let vc = storyboard?.instantiateViewController(withIdentifier: "WebView") as? WebViewController {
            vc.url = track["event"]["url"].stringValue
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}