//
//  Constants.swift
//  MusicApp
//
//  Created by Nick Arcuri on 6/19/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit

struct Constants {
    static let sptClientId: String = "dbd03522fff447e18b4097c2e2c0ae58"
    static let sptScopes: String = "streaming playlist-read-private playlist-modify-private playlist-modify-public user-read-private"
    static let sptCallback: String = "musicapp://auth/callback"
    static let apiURL: String = Bundle.main.infoDictionary!["API_ENDPOINT"] as! String
    static let dbDate: String = "yyyy-MM-dd'T'HH:mm:ss"
    
    static let sptGreen: UIColor = UIColor(red: 30 / 255, green: 215 / 255, blue: 96 / 255, alpha: 1.0)
}

struct UserDefatultsKeys {
    static let sptCode: String = "SPTCode"
    static let sptAccessToken: String = "SPTAccessToken"
    static let sptRefreshCode: String = "SPTRefreshCode"
    static let sptCodeExpires: String = "SPTCodeExpires"
    static let sptUsername: String = "SPTUsername"
    static let sptPlaylistId: String = "SPTPlaylistId"
    static let cityDefault: String = "userCity"
}
