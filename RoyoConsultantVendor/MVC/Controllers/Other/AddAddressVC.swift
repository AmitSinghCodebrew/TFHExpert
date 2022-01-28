//
//  AddAddressVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 14/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
#if HealExpert || HomeDoctorKhalidExperts
import GoogleMaps
#endif
import JVFloatLabeledTextField

class AddAddressVC: UIViewController {
    
    @IBOutlet weak var lblAddAddress: UILabel!
    #if HealExpert || HomeDoctorKhalidExperts
    @IBOutlet weak var mapView: GMSMapView!
    #endif
    @IBOutlet weak var lblSelectDeliveryAddress: UILabel!
    @IBOutlet weak var lblCurrentLocation: UILabel!
    @IBOutlet weak var tfLocation: JVFloatLabeledTextField!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnAdd: SKButton!
    
    var address: Address?
    var didSelected: ((_ addess: Address?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentLocation = LocationManager.shared.locationData
        
        #if HealExpert || HomeDoctorKhalidExperts
        generateAddress(latLng: address ?? Address(currentLocation.latitude, currentLocation.longitude, nil))
        moveToCurrentLcoation()
        #endif
        localizedTextSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        LocationManager.shared.startTrackingUser { [weak self] (location) in
            #if HealExpert || HomeDoctorKhalidExperts
            self?.moveToCurrentLcoation()
            self?.generateAddress(latLng: Address(location.latitude, location.longitude, nil))
            #endif
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Add
            didSelected?(address)
            popVC()
        case 2: //Edit
            #if HomeDoctorKhalidExperts
            GooglePlacePicker.shared.show { [weak self] (place) in
                self?.tfLocation.text = /place.name
                self?.address = Address(place.coordinate.latitude, place.coordinate.longitude, /place.name)
            }
            #endif
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension AddAddressVC {
    private func localizedTextSetup() {
        lblAddAddress.text = VCLiteral.ADD_ADDRESS.localized
        lblSelectDeliveryAddress.text = VCLiteral.SELECT_DELIVERY_ADDRESS.localized
        lblCurrentLocation.text = VCLiteral.CURRENT_LOCATION.localized
        lblCurrentLocation.isHidden = true
        tfLocation.placeholder = VCLiteral.LOCATION.localized
        tfLocation.isUserInteractionEnabled = false
        btnChange.setTitle(VCLiteral.EDIT.localized, for: .normal)
        btnAdd.setTitle(VCLiteral.ADD_ADDRESS.localized, for: .normal)
    }
    #if HealExpert || HomeDoctorKhalidExperts
    private func moveToCurrentLcoation() {
        let camera = GMSCameraPosition.camera(withLatitude: LocationManager.shared.locationData.latitude,
                                              longitude: LocationManager.shared.locationData.longitude,
                                              zoom: 16)
        mapView.camera = camera
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        
    }
    #endif
    
    #if HealExpert || HomeDoctorKhalidExperts
    //MARK:- Get Address String from latitude longitude
    private func generateAddress(latLng: Address?) {
       let location = CLLocation.init(latitude: /latLng?.latitude, longitude: /latLng?.longitude)
       CLGeocoder().reverseGeocodeLocation(location) { [weak self] (clPlacemark, error) in
           guard let placeMark = clPlacemark?.first else {
               print("No placemark from Apple: \(String(describing: error))")
               return
           }
           var address: String = ""
           
           // Location name
           if let locationName = placeMark.name {
               address += locationName
           }
           
           // Street address
           if let street = placeMark.thoroughfare {
               if !address.contains(street) {
                   address += ", " + street
               }
           }
           
           // City
           if let city = placeMark.locality {
               if !address.contains(city) {
                   address += ", " + city
               }
           }
           
           // Zip code
           if let zip = placeMark.postalCode {
               if !address.contains(zip) {
                   address += ", " + zip
               }
           }
           
           // SubAdministrativeArea
           if let submins = placeMark.subAdministrativeArea {
               if !address.contains(submins) {
                   address += ", " + submins
               }
           }
           
           // Country
           if let country = placeMark.country {
               if !address.contains(country) {
                   address += " - " + country
               }
           }
           self?.tfLocation.text = /address
           self?.address = latLng
           self?.address?.name = /address
       }
    }
    #endif
}

#if HealExpert || HomeDoctorKhalidExperts
//MARK:- GMSMapView Delegate
extension AddAddressVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let latitude = mapView.getCenterCoordinate().latitude
        let longitude = mapView.getCenterCoordinate().longitude
        generateAddress(latLng: Address.init(latitude, longitude, nil))
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        moveToCurrentLcoation()
        return true
    }
}


extension GMSMapView {
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = center
        let centerCoordinate = projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        let topCenterCoor = convert(CGPoint(x: frame.size.width / 2.0, y: 0), from: self)
        let point = projection.coordinate(for: topCenterCoor)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        
        let centerCoordinate = getCenterCoordinate()
        // init center location from center coordinate
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        
        return round(radius)
    }
}
#endif
