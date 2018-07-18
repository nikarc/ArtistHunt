//
//  MediaPlayer.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/7/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import Foundation
import SwiftyJSON
import AVFoundation
import MediaPlayer

enum TrackSkipDirection {
    case next
    case prev
}

typealias MediaPlayerTrackCallback = (_ tracks: JSON?, _ error: Error?) -> ()

protocol MediaPlayerDelegate {
    func didStartPlayingTrack(_ trackUri: String)
    func didChangePlaybackStatus(_ isPlaying: Bool)
}

class MediaPlayer: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    static let shared = MediaPlayer()
    
    let defaults = UserDefaults.standard
    let commandCenter = MPRemoteCommandCenter.shared()
    let nowPlayingInfo = MPNowPlayingInfoCenter.default()
    let dateFormatter = DateFormatter()
    
    var delegate: MediaPlayerDelegate?
    var player = SPTAudioStreamingController.sharedInstance()
    var tracks: JSON?
    var currentPlayingTrackIndex: Int?
    var currentPlayingTrack: JSON?
    
    
    private override init() {
        super.init()
        
        dateFormatter.dateFormat = Constants.dbDate
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let player = player {
            player.playbackDelegate = self
            player.delegate = self
            
            try! player.start(withClientId: Constants.sptClientId)
            if let accessToken = defaults.object(forKey: UserDefatultsKeys.sptAccessToken) as? String {
                player.login(withAccessToken: accessToken)
            }
        }
        
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPause({ (_) in })
            return .success
        }
        
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPause({ (_) in })
            
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.switchTrack(context: .next, { (_) in })
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.switchTrack(context: .prev, { (_) in })
            
            return .success
        }
    }
    
    func getPlaylist(_ callback: @escaping MediaPlayerTrackCallback) {
        if tracks == nil {
            ApiService.shared.getPlaylist { [unowned self] (_tracks, error) in
                guard error == nil else {
                    callback(nil, error)
                    return
                }
                
                guard _tracks != nil else {
                    callback(nil, nil)
                    return
                }
                
                self.tracks = _tracks!
                callback(self.tracks, nil)
            }
        } else {
            callback(tracks, nil)
        }
    }
    
    func loadAlbumArt() -> Data? {
        if player != nil, let currentPlayingTrack = currentPlayingTrack {
            // load up image
            let imageUrlString = currentPlayingTrack["album"]["images"][0]["url"].stringValue
            
            if let imageUrl = URL(string: imageUrlString), let data = try? Data(contentsOf: imageUrl) {
                return data
            }
        }
        
        return nil
    }
    
    func playTrack(_ track: JSON, trackIndex: Int, callback: @escaping SPTErrorableOperationCallback) {
        currentPlayingTrack = track
        currentPlayingTrackIndex = trackIndex
        
        player?.playSpotifyURI(track["uri"].stringValue, startingWith: 0, startingWithPosition: 0, callback: callback)
    }
    
    func playPause(_ callback: @escaping SPTErrorableOperationCallback)  {
        if let player = player, player.playbackState != nil {
            player.setIsPlaying(!player.playbackState.isPlaying, callback: callback)
        }
    }
    
    func switchTrack(context: TrackSkipDirection, _ callback: @escaping SPTErrorableOperationCallback) {
        if let player = player, let currentPlayingTrackIndex = currentPlayingTrackIndex, let tracks = tracks {
            switch context {
            case .next:
                if currentPlayingTrackIndex == tracks.count - 1 {
                    // Go back to first track
                    self.currentPlayingTrackIndex = 0
                } else {
                    self.currentPlayingTrackIndex = currentPlayingTrackIndex + 1
                }
            default:
                if currentPlayingTrackIndex == 0 {
                    // Go to last track
                    self.currentPlayingTrackIndex = tracks.count - 1
                } else {
                    self.currentPlayingTrackIndex = currentPlayingTrackIndex - 1
                }
            }
            
            self.currentPlayingTrack = tracks[self.currentPlayingTrackIndex!]
            let uri = self.currentPlayingTrack!["uri"].stringValue
            player.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0, callback: callback)
        }
    }
    
    func replayTrack(_ callback: @escaping SPTErrorableOperationCallback) {
        if let track = currentPlayingTrack {
            player?.playSpotifyURI(track["uri"].stringValue, startingWith: 0, startingWithPosition: 0, callback: callback)
        }
    }
    
    func activateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
            
            guard let currentPlayingTrack = currentPlayingTrack else { return }
            URLSession.shared.dataTask(with: URL(string: currentPlayingTrack["album"]["images"][0]["url"].stringValue)!) { (data, response, error) in
                guard error == nil, data != nil else {
                    print("Error getting album artwork for now playing")
                    return
                }
                
                guard let image = UIImage(data: data!) else { return }
                let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 50, height: 50), requestHandler: { (_) -> UIImage in
                    return image
                })
                
                self.nowPlayingInfo.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: currentPlayingTrack["title"].stringValue,
                    MPMediaItemPropertyArtist: currentPlayingTrack["artists"].map({ $0.1["name"].stringValue }).joined(separator: ", "),
                    MPMediaItemPropertyAlbumTitle: currentPlayingTrack["album"]["title"].stringValue,
                    MPMediaItemPropertyPlaybackDuration: currentPlayingTrack["duration_ms"].intValue / 1000,
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0,
                    MPMediaItemPropertyArtwork: artwork
                ]
            }.resume()
        } catch let error {
            print("error establishing audio session: \(error)")
        }
    }
    
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

// Delegate methods

extension MediaPlayer {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        delegate?.didStartPlayingTrack(trackUri)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        delegate?.didChangePlaybackStatus(isPlaying)
        
        if isPlaying {
            activateAudioSession()
        } else {
            deactivateAudioSession()
        }
    }
}
