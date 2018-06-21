//
//  Constants.swift
//  MusicApp
//
//  Created by Nick Arcuri on 6/19/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit

struct Constants {
    // TODO: - Get from env variable
    static let sptClientId: String = "dbd03522fff447e18b4097c2e2c0ae58"
    static let sptScopes: String = "streaming playlist-read-private playlist-modify-public user-read-private"
    static let sptCallback: String = "musicapp://auth/callback"
    
    // SPT User default keys
    static let sptCode: String = "SPTCode"
    
    static let cityDefault: String = "userCity"
    
    static let apiURL: String = "http://localhost:8083"
}
