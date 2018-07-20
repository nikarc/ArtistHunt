//
//  MediaPlayerContainerViewController.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/3/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol MediaPlayerContainerDelegate {
    func mediaPlayerAnimationComplete()
}

class MediaPlayerContainerViewController: UIViewController, MediaPlayerControllerDelegate, PlaylistTableViewDelegate {

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var playlistTableViewContainer: UIView!
    
    var delegate: MediaPlayerContainerDelegate?
    var mediaPlayerContainer: MediaPlayerViewController?
    var initialBottomLayoutConstant: CGFloat?
    var loadingView: LoadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialBottomLayoutConstant = bottomLayoutConstraint.constant
        
        if let navController = storyboard?.instantiateViewController(withIdentifier: "NavController") as? UINavigationController {
            addChildViewController(navController)
            playlistTableViewContainer.addSubview(navController.view)
            
            navController.view.translatesAutoresizingMaskIntoConstraints = false
            navController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            navController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            navController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            navController.view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            
            if let playlistVC = navController.viewControllers.first as? PlaylistTableViewController {
                playlistVC.delegate = self
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MediaPlayerSegue" {
            if let vc = segue.destination as? MediaPlayerViewController {
                vc.delegate = self
                
                self.delegate = vc
            }
        }
    }

}


extension MediaPlayerContainerViewController {
    func stateToggled(_ state: MediaPlayerViewState) {
        switch state {
        case .collapsed:
            // Media Player is collapsed, expand
            bottomLayoutConstraint.constant = 64
        case .expanded:
            // Media player is expanded, collapse
            bottomLayoutConstraint.constant = initialBottomLayoutConstant!
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.delegate?.mediaPlayerAnimationComplete()
        }
    }
    
    func venueButtonClicked(track: JSON) {
        if let navController = childViewControllers.last as? UINavigationController {
            if let vc = navController.viewControllers.first as? PlaylistTableViewController {
                vc.openVenueDetailView(tracks: [track], shouldPopVc: true)
            }
        }
    }
}

extension MediaPlayerContainerViewController {
    func beginLoadingTracks() {
        view.addSubview(loadingView)
        loadingView.make()
    }
    
    func doneLoadingTracks() {
        loadingView.destroy()
    }
}
