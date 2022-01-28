//
//  CardExpiryTF.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 24/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class CardExpiryTF: UITextField {
    
    
    public func setup() {
        delegate = self
    }
}

extension CardExpiryTF: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        let currentCharacterCount = updatedText.count
        if string == "" {
            if currentCharacterCount == 3 {
                textField.text = "\(updatedText.prefix(1))"
                return false
            }
            return true
        } else if updatedText.count == 5 {
            
            expDateValidation(dateStr: updatedText)
            return true
        } else if updatedText.count > 5 {
            
            return false
        } else if updatedText.count == 1 {
            
            if updatedText > "1" {
                return false
            }
        } else if updatedText.count == 2 { //Prevent user to not enter month more than 12
            if updatedText > "12" {
                return false
            }
        }
        if updatedText.count == 2 {
            textField.text = "\(updatedText)/" //This will add "/" when user enters 2nd digit of month
        } else {
            textField.text = updatedText
        }
        return false
    }
    
    func expDateValidation(dateStr:String) {
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100   // This will give you current year (i.e. if 2019 then it will be 19)
        let currentMonth = Calendar.current.component(.month, from: Date()) // This will give you current month (i.e if June then it will be 6)
        
        let enteredYear = Int(dateStr.suffix(2)) ?? 0 // get last two digit from entered string as year
        let enteredMonth = Int(dateStr.prefix(2)) ?? 0 // get first two digit from entered string as month
        print(dateStr) // This is MM/YY Entered by user
        
        if enteredYear > currentYear {
            if (1 ... 12).contains(enteredMonth) {
                print("Entered Date Is Right")
            } else {
                print("Entered Date Is Wrong")
            }
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                if (1 ... 12).contains(enteredMonth) {
                    print("Entered Date Is Right")
                } else {
                    print("Entered Date Is Wrong")
                }
            } else {
                print("Entered Date Is Wrong")
            }
        } else {
            print("Entered Date Is Wrong")
        }
        
    }
}
