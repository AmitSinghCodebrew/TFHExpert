//
//  LocationRequestVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 06/10/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class LocationRequestVC: BaseVC {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnUseLocation: SKButton!
    @IBOutlet weak var btnSkipLocation: SKBorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizableTextSetup()
        UserPreference.shared.isLocationScreenSeen = true
    }
    
    deinit {
        LocationManager.shared.startTrackingUser(didChangeLocation: nil)
    }
    
    @IBAction func btnAction(_ sender: SKLottieButton) {
        switch sender.tag {
        case 0: // Use my Location
            LocationManager.shared.startTrackingUser { (location) in
                let tabNavigationVC = Storyboard<LoginSignUpNavVC>.LoginSignUp.instantiateVC()
                UIWindow.replaceRootVC(tabNavigationVC)
            }
        case 1: // Skip for now
            let tabNavigationVC = Storyboard<LoginSignUpNavVC>.LoginSignUp.instantiateVC()
            UIWindow.replaceRootVC(tabNavigationVC)
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension LocationRequestVC {
    private func localizableTextSetup() {
        lblTitle.text = VCLiteral.ALLOW_LOCATION.localized
        lblDesc.text = VCLiteral.ALLOW_LOCATION_DESC.localized
        btnUseLocation.setTitle(VCLiteral.USE_MY_LOCATION.localized, for: .normal)
        btnSkipLocation.setTitle(VCLiteral.SKIP_FOR_NOW.localized, for: .normal)
        btnSkipLocation.semanticContentAttribute = L102Language.isRTL ? .forceLeftToRight : .forceRightToLeft
        btnSkipLocation.imageEdgeInsets.left = L102Language.isRTL ? 0 : 16
        btnSkipLocation.imageEdgeInsets.right = L102Language.isRTL ? 16 : 0
    }
}
