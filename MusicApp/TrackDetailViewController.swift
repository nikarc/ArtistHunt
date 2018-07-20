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
    
    var tracks: [JSON]?

    let regionRadius: CLLocationDistance = 800
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueInfo: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let track = tracks?[0] {
            self.title = track["name"].stringValue
            
            let venue = track["event"]["venue"]
            let lat = venue["location"]["lat"].doubleValue
            let lon = venue["location"]["lon"].doubleValue
            
            let initialLocation = CLLocation(latitude: lat, longitude: lon)
            centerMapOnLocation(location: initialLocation)
            
            var venueName = venue["name"].stringValue
            let date = track["event"]["datetime_local"].stringValue
            
            let inputDateFormatter = DateFormatter()
            inputDateFormatter.dateFormat = Constants.dbDate
            inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "MMM dd yyyy h:mm a"
            
            if let dateObject = inputDateFormatter.date(from: date) {
                let dateString = outputDateFormatter.string(from: dateObject)
                
                venueName += " - \(dateString)"
            }
            
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
        if let track = tracks?[0], let vc = storyboard?.instantiateViewController(withIdentifier: "WebView") as? WebViewController {
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
