//
//  ApiService.swift
//  MusicApp
//
//  Created by Nick Arcuri on 6/19/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias EmptyAPICallback = (_ error: Error?) -> ()
typealias PlaylistCallback = (_ data: JSON?, _ error: Error?) -> ()

class ApiService: NSObject {
    
    static let shared = ApiService()
    
    var tracks: JSON?
    
    static let defaults = UserDefaults.standard
    
    static func loginToSpotify() {
        if let uriEncoded = Constants.sptScopes.encodeURIComponent() {
            let sptURL = URL(string: "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Constants.sptClientId)&scope=\(uriEncoded)&redirect_uri=\(Constants.sptCallback)")!
            UIApplication.shared.open(sptURL, options: [:], completionHandler: nil)
        }
    }
    
    static func createUser(code: String, _ callback: @escaping EmptyAPICallback) {
        if let city = defaults.object(forKey: UserDefatultsKeys.cityDefault) {
            let params: Parameters = [
                "code": code,
                "city": city
            ]
            
            // Set user default for spt token
            defaults.set(code, forKey: UserDefatultsKeys.sptCode)
            let url = "\(Constants.apiURL)/api/signup"
            print("Signup url: \(url)")
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(_):
                        let json = JSON(response.data!)
                        defaults.set(json["access_token"].stringValue, forKey: UserDefatultsKeys.sptAccessToken)
                        defaults.set(json["refresh_token"].stringValue, forKey: UserDefatultsKeys.sptRefreshCode)
                        defaults.set(json["username"].stringValue, forKey: UserDefatultsKeys.sptUsername)
                        defaults.set(json["playlistId"].stringValue, forKey: UserDefatultsKeys.sptPlaylistId)
                        // Add 1 hour to current time - the time that the token will expire
                        let calendar = Calendar.current
                        if let expireTime = calendar.date(byAdding: .hour, value: 1, to: Date()) {
                            defaults.set(expireTime, forKey: UserDefatultsKeys.sptCodeExpires)
                        }
                        callback(nil)
                    case .failure(let error):
                        callback(error)
                    }
            }
        }
    }
    
    static func refreshSPTToken(_ callback: @escaping EmptyAPICallback) {
        if let refreshToken = defaults.object(forKey: UserDefatultsKeys.sptRefreshCode) as? String, let userame = defaults.object(forKey: UserDefatultsKeys.sptUsername) as? String {
            let params: Parameters = [
                "refreshToken": refreshToken,
                "username": userame
            ]
            
            Alamofire.request("\(Constants.apiURL)/api/refreshSPTToken", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        let accessToken = json["accessToken"].stringValue
                        
                        let calendar = Calendar.current
                        let now = Date()
                        let date = calendar.date(byAdding: .hour, value: 1, to: now)
                        
                        defaults.set(accessToken, forKey: UserDefatultsKeys.sptAccessToken)
                        defaults.set(date, forKey: UserDefatultsKeys.sptCodeExpires)
                        
                        callback(nil)
                    case .failure(let error):
                        callback(error)
                    }
            }
        }
    }
    
    func getPlaylist(_ callback: @escaping PlaylistCallback) {
        if let tracks = self.tracks {
            callback(tracks, nil)
        } else if let username = ApiService.defaults.object(forKey: UserDefatultsKeys.sptUsername) as? String, let accessToken = ApiService.defaults.object(forKey: UserDefatultsKeys.sptAccessToken) as? String {
            let params: Parameters = [
                "username": username,
                "accessToken": accessToken
            ]
            
            Alamofire.request("\(Constants.apiURL)/api/getUserPlaylist", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .validate(statusCode: 200..<300)
                .responseJSON { [unowned self] (response) in
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        self.tracks = json["playlist"]["tracks"]
                        callback(json, nil)
                    case .failure(let error):
                        callback(nil, error)
                    }
            }
        }
    }
}
