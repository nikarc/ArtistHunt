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

class MediaPlayerContainerViewController: UIViewController {

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var delegate: MediaPlayerContainerDelegate?
    var mediaPlayerContainer: MediaPlayerViewController?
    var initialBottomLayoutConstant: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialBottomLayoutConstant = bottomLayoutConstraint.constant
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


extension MediaPlayerContainerViewController: MediaPlayerControllerDelegate {
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
        print("Child view controllers: \(childViewControllers)")
        if let navController = childViewControllers.first as? UINavigationController {
            if let vc = navController.viewControllers.first as? PlaylistTableViewController {
                vc.openVenueDetailView(track: track, shouldPopVc: true)
            }
        }
    }
}
