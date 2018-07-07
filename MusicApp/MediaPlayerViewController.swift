//
//  MediaPlayerViewController.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/3/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftIcons

enum MediaPlayerViewState {
    case collapsed
    case expanded
}

protocol MediaPlayerControllerDelegate {
    func stateToggled(_ state: MediaPlayerViewState)
}

class MediaPlayerViewController: UIViewController, MediaPlayerDelegate {
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var prevTrackButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    let mediaPlayer = MediaPlayer.shared
    let defaults = UserDefaults.standard
    let albumImageHeight: CGFloat = 200
    let playPauseButtonIconSize: CGFloat = 30
    let trackSkipButtonSize: CGFloat = 20
    
    var delegate: MediaPlayerControllerDelegate?
    var screenHeight: CGFloat?
    var state: MediaPlayerViewState = .collapsed
    var tracks: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaPlayer.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        screenHeight = UIScreen.main.bounds.height

        buttonView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonView.insertSubview(blurView, at: 0)
        
        upArrow.setIcon(icon: .dripicon(.chevronUp), iconSize: 20, color: .gray, backgroundColor: .clear, forState: .normal)
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: playPauseButtonIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        nextTrackButton.setIcon(icon: .ionicons(.skipForward), iconSize: trackSkipButtonSize, color: .gray, backgroundColor: .clear, forState: .normal)
        prevTrackButton.setIcon(icon: .ionicons(.skipBackward), iconSize: trackSkipButtonSize, color: .gray, backgroundColor: .clear, forState: .normal)
        
        imageView.contentMode = .scaleAspectFit
        
        prevTrackButton.addTarget(self, action: #selector(prevTrack(_:event:)), for: .touchDownRepeat)
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
            
            mediaPlayer.getPlaylist { (tracks, error) in
                guard error == nil else {
                    self.showAlert(title: "Oops!", message: "Error getting tracks: \(error!.localizedDescription)")
                    return
                }
                
                guard tracks != nil else { return }
                
                self.tracks = tracks!
                self.tableView.reloadData()
            }
        case .expanded:
            // Media player is expanded, collapse
            state = .collapsed
            imageHeight.constant = 0
        }
    }
    
    func loadAlbumArt() {
        if let imageData = mediaPlayer.loadAlbumArt() {
            imageView.image = UIImage(data: imageData)
            if imageHeight.constant != albumImageHeight {
                imageHeight.constant = albumImageHeight
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                    self.imageViewContainer.backgroundColor = UIColor(red: 55 / 255, green: 55 / 255, blue: 55 / 255, alpha: 1)
                }
            }
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
            mediaPlayer.playTrack(track, trackIndex: indexPath.row) { (error) in
                guard error == nil else {
                    self.showAlert(title: "Oops!", message: "Error playing song: \(error!.localizedDescription)")
                    return
                }
            }
        }
    }
}

// Playback methods
extension MediaPlayerViewController {
    @IBAction func playPause(_ sender: Any) {
        mediaPlayer.playPause { (error) in
            guard error == nil else {
                self.showAlert(title: "Oops!", message: "There was an error during playback: \(error!.localizedDescription)")
                return
            }
        }
    }
    
    @IBAction func nextTrack(_ send: Any) {
        mediaPlayer.switchTrack(context: .next) { (error) in
            guard error == nil else {
                self.showGenericErrorAlert(error: error!)
                return
            }
        }
    }
    
    @objc func prevTrack(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if touch.tapCount == 2 {
            mediaPlayer.switchTrack(context: .prev) { (error) in
                guard error == nil else {
                    self.showGenericErrorAlert(error: error!)
                    return
                }
            }
        }
    }
}

// Delegate methods
extension MediaPlayerViewController {
    func didStartPlayingTrack(_ trackUri: String) {
        loadAlbumArt()
    }
    
    func didChangePlaybackStatus(_ isPlaying: Bool) {
        if isPlaying {
            playPauseButton.setIcon(icon: .ionicons(.pause), iconSize: playPauseButtonIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        } else {
            playPauseButton.setIcon(icon: .ionicons(.play), iconSize: playPauseButtonIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        }
    }
}
