//
//  AppDelegate.swift
//  MusicApp
//
//  Created by Nick Arcuri on 6/16/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = UserDefaults()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Check for spotify token. if exists, skip login
        if defaults.object(forKey: UserDefatultsKeys.sptCode) != nil && defaults.object(forKey: UserDefatultsKeys.sptUsername) != nil {
            if let expiresIn = defaults.object(forKey: UserDefatultsKeys.sptCodeExpires) as? Date {
                let timeDifference = Int(Date().timeIntervalSince(expiresIn))
                if timeDifference >= 0 {
                    // Greater than 1 hour, token has expired, needs refresh
                    ApiService.refreshSPTToken { [unowned self] (error) in
                        guard error == nil else { return }
                        self.setInitialView("MediaPlayerContainer")
                    }
                } else {
                    // token does NOT need to be refreshed, go to playist table view
                    setInitialView("MediaPlayerContainer")
                }
            }
        } else {
            setInitialView("SignupView")
        }
        
        GMSPlacesClient.provideAPIKey("AIzaSyAG9y2zx-9ri0Ijy_aUbqUryR8gBUq91bM")
        
        return true
    }
    
    /**
        Set initial VC to app navigation controller (skip initial signup)
    */
    func setInitialView(_ storyboardId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if storyboardId == "MediaPlayerContainer" {
            if let navigationController = storyboard.instantiateViewController(withIdentifier: storyboardId) as? MediaPlayerContainerViewController {
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }
        } else if storyboardId == "SignupView" {
            if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupNavController") as? UINavigationController {
                window?.rootViewController = signupVC
                window?.makeKeyAndVisible()
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        // TODO: Show some kind of loading screen over signup so that user knows something is happening
        if let code = queryItems?.filter({ $0.name == "code" }).first?.value {
            ApiService.createUser(code: code) { [unowned self] (error) in
                guard error == nil else {
                    print("There was an error \(error!.localizedDescription)")
                    if let rootVC = self.window?.rootViewController {
                        rootVC.showAlert(title: "Oops!", message: "There was an error signing up: \(error!.localizedDescription)")
                    }
                    return
                }
                
                self.setInitialView("MediaPlayerContainer")
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

