//
//  UILabelExtension.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 26/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

extension UILabel {
    func setAtrributedText(original: (text: String, font: UIFont, color: UIColor), toReplace: (text: String, font: UIFont, color: UIColor)) {
        
        let originalAttributes = [NSAttributedString.Key.foregroundColor : original.color,
                                  NSAttributedString.Key.font: original.font]
        
        let replacableAttributes = [NSAttributedString.Key.foregroundColor : toReplace.color,
                                    NSAttributedString.Key.font: toReplace.font]
        
        let mutableAttributedString = NSMutableAttributedString.init(string: original.text, attributes: originalAttributes)
        let toReplaceText = NSMutableAttributedString.init(string: toReplace.text, attributes: replacableAttributes)
        
        if let rangeToReplace = original.text.range(of: toReplace.text) {
            mutableAttributedString.replaceCharacters(in: NSRange.init(rangeToReplace, in: original.text), with: toReplaceText)
        }
        
        attributedText = mutableAttributedString
    }
}

