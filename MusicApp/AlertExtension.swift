//
//  AlertExtension.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/2/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
}
