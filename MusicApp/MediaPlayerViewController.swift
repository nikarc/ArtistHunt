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

class MediaPlayerViewController: UIViewController, MediaPlayerDelegate, MediaPlayerContainerDelegate {
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var prevTrackButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currentTrackLabel: UILabel!
    
    let mediaPlayer = MediaPlayer.shared
    let defaults = UserDefaults.standard
    let albumImageHeight: CGFloat = 200
    let playPauseButtonIconSize: CGFloat = 30
    let trackSkipButtonSize: CGFloat = 20
    let selectedTrackColor: UIColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    let upArrowIconSize: CGFloat = 20
    
    var delegate: MediaPlayerControllerDelegate?
    var screenHeight: CGFloat?
    var state: MediaPlayerViewState = .collapsed
    var tracks: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderTop = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        let colorValue: CGFloat = 204 / 255
        borderTop.backgroundColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)
        view.addSubview(borderTop)
        borderTop.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        borderTop.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        borderTop.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        mediaPlayer.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        screenHeight = UIScreen.main.bounds.height

        buttonView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonView.insertSubview(blurView, at: 0)
        
        upArrow.setIcon(icon: .dripicon(.chevronUp), iconSize: upArrowIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        playPauseButton.setIcon(icon: .ionicons(.play), iconSize: playPauseButtonIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        nextTrackButton.setIcon(icon: .ionicons(.skipForward), iconSize: trackSkipButtonSize, color: .gray, backgroundColor: .clear, forState: .normal)
        prevTrackButton.setIcon(icon: .ionicons(.skipBackward), iconSize: trackSkipButtonSize, color: .gray, backgroundColor: .clear, forState: .normal)
        
        imageView.contentMode = .scaleAspectFit
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(replayTrack(_:)))
        singleTap.numberOfTapsRequired = 1
        prevTrackButton.addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(prevTrack(_:)))
        doubleTap.numberOfTapsRequired = 2
        prevTrackButton.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        currentTrackLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upButtonPressed(_ sender: Any) {
        switch state {
        case .collapsed:
            // Media player is collapsed, expand
            if let _ = self.tracks {
                self.delegate?.stateToggled(self.state)
                self.state = .expanded
            } else {
                mediaPlayer.getPlaylist { (tracks, error) in
                    guard error == nil else {
                        self.showAlert(title: "Oops!", message: "Error getting tracks: \(error!.localizedDescription)")
                        return
                    }
                    
                    guard tracks != nil else { return }
                    
                    self.tracks = tracks!
                    self.tableView.reloadData()
                    
                    self.delegate?.stateToggled(self.state)
                    self.state = .expanded
                }
            }
        case .expanded:
            // Media player is expanded, collapse
            imageHeight.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                self.delegate?.stateToggled(self.state)
                self.state = .collapsed
            }
        }
    }
    
    func loadAlbumArt() {
        if let imageData = mediaPlayer.loadAlbumArt() {
            imageView.image = UIImage(data: imageData)
            if imageHeight.constant != albumImageHeight && self.state != .collapsed {
                imageHeight.constant = albumImageHeight
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                    self.imageViewContainer.backgroundColor = UIColor(red: 55 / 255, green: 55 / 255, blue: 55 / 255, alpha: 1)
                }
            }
        }
    }
    
    func changeCellTextColor(fromIndex: Int?, toIndex: Int, toColor: UIColor) {
        if let fromIndex = fromIndex {
            // Set track back to inital color
            let fromIndexPath = IndexPath(row: fromIndex, section: 0)
            let fromCell = tableView.cellForRow(at: fromIndexPath)
            fromCell?.textLabel?.textColor = .black
            fromCell?.detailTextLabel?.textColor = .black
        }
        
        // Set new track to new color
        let toIndexPath = IndexPath(row: toIndex, section: 0)
        let toCell = tableView.cellForRow(at: toIndexPath)
        toCell?.textLabel?.textColor = toColor
        toCell?.detailTextLabel?.textColor = toColor
    }
    
    func changeCurrentTrackLabel() {
        if let tracks = self.tracks, let index = mediaPlayer.currentPlayingTrackIndex {
            let track = tracks[index]
            
            let trackNameText = "\(track["name"].stringValue) •"
            let trackNameTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
            
            let attributedText = NSMutableAttributedString(string: trackNameText, attributes: trackNameTextAttributes)
            
            let artistText = " \(track["artists"].map({ $0.1["name"].stringValue }).joined(separator: ", "))"
            let attributedArtistText = NSMutableAttributedString(string: artistText)
            
            attributedText.append(attributedArtistText)
            
            currentTrackLabel.attributedText = attributedText
        }
    }

}

// MARK: - Table View Delegate Methods
extension MediaPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks?.arrayValue.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
        
        cell.selectionStyle = .none
        
        if let track = tracks?[indexPath.row] {
            cell.textLabel?.text = track["name"].stringValue
            cell.detailTextLabel?.text = track["artists"].map({ $0.1["name"].stringValue }).joined(separator: ", ")
        }
        
        return cell
    }
    
    // TODO: - This is affecting multiple cells, the same cell index after scroll refresh is colored
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let track = tracks?[indexPath.row] {
            if mediaPlayer.currentPlayingTrack != nil, let trackName = mediaPlayer.currentPlayingTrack?["name"].stringValue {
                if trackName == track["name"].stringValue {
                    cell.textLabel?.textColor = self.selectedTrackColor
                }
            }
        }
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

// MARK: - Playback methods
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
        let initialTrackIndex = mediaPlayer.currentPlayingTrackIndex
        mediaPlayer.switchTrack(context: .next) { (error) in
            guard error == nil else {
                self.showGenericErrorAlert(error: error!)
                return
            }
            if let trackIndex = self.mediaPlayer.currentPlayingTrackIndex {
                self.changeCellTextColor(fromIndex: initialTrackIndex, toIndex: trackIndex, toColor: self.selectedTrackColor)
            }
        }
    }
    
    @objc func prevTrack(_ sender: UIButton) {
        let initialTrackIndex = mediaPlayer.currentPlayingTrackIndex
        mediaPlayer.switchTrack(context: .prev) { (error) in
            guard error == nil else {
                self.showGenericErrorAlert(error: error!)
                return
            }
            if let trackIndex = self.mediaPlayer.currentPlayingTrackIndex {
                self.changeCellTextColor(fromIndex: initialTrackIndex, toIndex: trackIndex, toColor: self.selectedTrackColor)
            }
        }
    }
    
    @objc func replayTrack(_ sender: UIButton) {
        mediaPlayer.replayTrack { (error) in
            guard error == nil else {
                self.showGenericErrorAlert(error: error!)
                return
            }
        }
    }
}

// MARK: - Media Player Delegate methods
extension MediaPlayerViewController {
    func didStartPlayingTrack(_ trackUri: String) {
        loadAlbumArt()
        changeCurrentTrackLabel()
        
        tableView.reloadData()
    }
    
    func didChangePlaybackStatus(_ isPlaying: Bool) {
        if isPlaying {
            playPauseButton.setIcon(icon: .ionicons(.pause), iconSize: playPauseButtonIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        } else {
            playPauseButton.setIcon(icon: .ionicons(.play), iconSize: playPauseButtonIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        }
    }
}

// MARK: - Media Player Container Delegate
extension MediaPlayerViewController {
    func mediaPlayerAnimationComplete() {
        if state == .expanded {
            if let _ = mediaPlayer.currentPlayingTrack {
                imageHeight.constant = albumImageHeight
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
            upArrow.setIcon(icon: .dripicon(.chevronDown), iconSize: upArrowIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        } else if state == .collapsed {
            upArrow.setIcon(icon: .dripicon(.chevronUp), iconSize: upArrowIconSize, color: .gray, backgroundColor: .clear, forState: .normal)
        }
    }
}
