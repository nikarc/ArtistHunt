//
//  MediaPlayerViewController.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/3/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import SwiftyJSON

enum MediaPlayerState {
    case collapsed
    case expanded
}

protocol MediaPlayerControllerDelegate {
    func stateToggled(_ state: MediaPlayerState)
}

class MediaPlayerViewController: UIViewController {
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: MediaPlayerControllerDelegate?
    var screenHeight: CGFloat?
    var state: MediaPlayerState = .collapsed
    var tracks: JSON?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        screenHeight = UIScreen.main.bounds.height

        buttonView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonView.insertSubview(blurView, at: 0)
        
        if let image = UIImage(named: "up_arrow_small") {
            upArrow.imageView?.contentMode = .scaleAspectFit
            upArrow.setImage(image, for: .normal)
            
            let insetScale: CGFloat = 5
            upArrow.imageEdgeInsets = UIEdgeInsetsMake(insetScale, insetScale, insetScale, insetScale)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upButtonPressed(_ sender: Any) {
        delegate?.stateToggled(state)
        switch state {
        case .collapsed:
            // Media player is collapsed, expand
            state = .expanded
            
            // If tracks are nil, populate
            if tracks == nil {
                ApiService.shared.getPlaylist { [unowned self] (tracks, error) in
                    guard error == nil else {
                        self.showAlert(title: "Oops!", message: "Error getting tracks: \(error!.localizedDescription)")
                        return
                    }
                    
                    guard tracks != nil else { return }
                    
                    self.tracks = tracks!
                    self.tableView.reloadData()
                }
            }
        case .expanded:
            // Media player is expanded, collapse
            state = .collapsed
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

extension MediaPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks?.arrayValue.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
        
        if let track = tracks?[indexPath.row] {
            cell.textLabel?.text = track["name"].stringValue
            cell.detailTextLabel?.text = track["artists"].map({ $0.1["name"].stringValue }).joined(separator: ", ")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let track = tracks?[indexPath.row] {
            print("Track: \(track)")
        }
    }
}
