//
//  AppButton.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/17/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit

class AppButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = Constants.systemBlue
        self.layer.cornerRadius = 3.0
        self.setTitleColor(.white, for: .normal)
    }
    
}
