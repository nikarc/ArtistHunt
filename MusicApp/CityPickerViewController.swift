//
//  CityPickerViewController.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/15/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import GooglePlaces

class CityPickerViewController: UIViewController {
    
    @IBOutlet weak var spotifySignInButton: AppButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Constants.appGray
        spotifySignInButton.isEnabled = false
    }
    

    
    @IBAction func showChooseCityPopup(_ sender: Any) {
        let autocompletePicker = GMSAutocompleteViewController()
        autocompletePicker.delegate = self
        autocompletePicker.modalTransitionStyle = .coverVertical
        
        let filter = GMSAutocompleteFilter()
        filter.type = .region
        
        autocompletePicker.autocompleteFilter = filter
        
        present(autocompletePicker, animated: true)
    }
    
    @IBAction func signInToSpotify(_ sender: Any) {
        ApiService.loginToSpotify()
    }
    
    
}

extension CityPickerViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let addressComponents = place.addressComponents else { return }
        
        for field in addressComponents {
            if field.type == kGMSPlaceTypeSublocalityLevel1 {
                let defaults = UserDefaults()
                defaults.set(field.name, forKey: UserDefatultsKeys.cityDefault)
            }
        }
        
        spotifySignInButton.isEnabled = true
        
        dismiss(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
