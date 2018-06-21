//
//  ApiService.swift
//  MusicApp
//
//  Created by Nick Arcuri on 6/19/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import Alamofire

typealias EmptyAPICallback = (_ error: Error?) -> ()

class ApiService: NSObject {
    static let defaults = UserDefaults.standard
    
    static func loginToSpotify() {
        if let uriEncoded = Constants.sptScopes.encodeURIComponent() {
            let sptURL = URL(string: "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Constants.sptClientId)&scope=\(uriEncoded)&redirect_uri=\(Constants.sptCallback)")!
            UIApplication.shared.open(sptURL, options: [:], completionHandler: nil)
        }
    }
    
    static func createUser(code: String, _ callback: @escaping EmptyAPICallback) {
        if let city = defaults.object(forKey: Constants.cityDefault) {
            let params: Parameters = [
                "code": code,
                "city": city
            ]
            
            Alamofire.request("\(Constants.apiURL)/api/signup", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(_):
                        callback(nil)
                    case .failure(let error):
                        callback(error)
                    }
            }
        }
    }
}
