//
//  MediaPlayerContainerViewController.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/3/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit

class MediaPlayerContainerViewController: UIViewController {

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
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


extension MediaPlayerContainerViewController: MediaPlayerControllerDelegate {
    func stateToggled(_ state: MediaPlayerState) {
        // do work
        switch state {
        case .collapsed:
            // Media Player is collapsed, expand
            bottomLayoutConstraint.constant = 70
        case .expanded:
            // Media player is expanded, collapse
            bottomLayoutConstraint.constant = initialBottomLayoutConstant!
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
