//
//  OTPTextField.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 12/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class OTPTextField: UITextField {
    
    var didTapBackward: (() -> Void)?
    
    override func deleteBackward() {
        super.deleteBackward()
        didTapBackward?()
    }
}
