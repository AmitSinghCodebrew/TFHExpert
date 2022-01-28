//
//  CvvTF.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 24/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class CvvTF: UITextField {
    
    let MAX_LENGTH_PHONENUMBER = 3
    let ACCEPTABLE_NUMBERS     = "0123456789"
    
    public func setup() {
        delegate = self
    }
}

extension CvvTF: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength: Int = (textField.text?.count ?? 0) + string.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        return (strValid && (newLength <= MAX_LENGTH_PHONENUMBER))
    }
}
