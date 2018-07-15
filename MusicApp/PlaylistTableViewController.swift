//
//  PlaylistTableViewController.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/1/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import SwiftyJSON

class PlaylistTableViewController: UITableViewController {
    
    var tracks: [JSON] = []
    
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = Constants.dbDate
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        ApiService.shared.getPlaylist { [unowned self] (json, error) in
            guard error == nil else {
                self.showAlert(title: "Oops!", message: "There was an error getting the playlist: \(error!.localizedDescription)")
                return
            }
            
            guard json != nil else {
                self.showAlert(title: "Oops!", message: "No data returned from playlist GET")
                return
            }
            
            self.tracks = json!["playlist"]["tracks"].arrayValue.sorted(by: { [unowned self] (prev, next) -> Bool in
                if let prevDate = self.dateFormatter.date(from: prev["event"]["datetime_local"].stringValue),
                    let nextDate = self.dateFormatter.date(from: next["event"]["datetime_local"].stringValue) {
                    return prevDate < nextDate
                }
                
                return prev["name"].stringValue < next["name"].stringValue
            })
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let track = self.tracks[indexPath.row]
        cell.textLabel?.text = track["name"].stringValue
        
        if let eventDate = dateFormatter.date(from: track["event"]["datetime_local"].stringValue) {
            let readableDateFormatter = DateFormatter()
            readableDateFormatter.dateFormat = "MMM d h:mm a"
            
            let dateString = readableDateFormatter.string(from: eventDate)
            cell.detailTextLabel?.text = "\(dateString) • \(track["event"]["venue"]["name"].stringValue)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        openVenueDetailView(track: track)
    }
    
    func openVenueDetailView(track: JSON, shouldPopVc: Bool = false) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TrackDetail") as? TrackDetailViewController {
            vc.track = track
            
            if shouldPopVc { self.navigationController?.popViewController(animated: false) }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
