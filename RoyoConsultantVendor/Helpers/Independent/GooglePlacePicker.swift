//
//  GooglePlacePicker.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 09/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//


import Foundation
import GooglePlaces

//Note:- change target of file to use in app
class GooglePlacePicker: NSObject {
    
    static let shared = GooglePlacePicker()
    private var didSelectPlace: ((_ place: GMSPlace) -> Void)?
    
    override init() {
        super.init()
        GMSPlacesClient.provideAPIKey(Configuration.getValue(for: .APP_GOOGLE_PLACES_KEY))
    }
    
    public func show(selectedPlace: ((_ place: GMSPlace) -> Void)?) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.primaryTextColor = ColorAsset.txtGrey.color
        autocompleteController.secondaryTextColor = ColorAsset.txtMoreDark.color
        autocompleteController.tableCellSeparatorColor = ColorAsset.shadow.color
        autocompleteController.tableCellBackgroundColor = ColorAsset.backgroundCell.color
        autocompleteController.primaryTextHighlightColor = ColorAsset.txtTheme.color
        autocompleteController.delegate = self
        didSelectPlace = selectedPlace
        UIApplication.topVC()?.presentVC(autocompleteController)
    }
}

//MARK:- VCFuncs
extension GooglePlacePicker: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        viewController.dismiss(animated: true) {
            UIApplication.topVC()?.alertBoxOKCancel(title: "Error", message: error.localizedDescription, tapped: {
            
            }, cancelTapped: nil)
        }
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismissVC()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        viewController.dismissVC()
        didSelectPlace?(place)
    }
}
