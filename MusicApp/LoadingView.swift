//
//  LoadingView.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/18/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingView: UIView {
    
    func make() {
        let superView = self.superview
        frame = CGRect(x: 0, y: 0, width: superView?.bounds.width ?? 0, height: superView?.bounds.height ?? 0)
        self.frame = frame
        
        let indicator = NVActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 100, height: 50), type: .ballPulse, color: .white, padding: 0)
        addSubview(indicator)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        indicator.startAnimating()
    }
    
    func destroy()  {
        self.removeFromSuperview()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
