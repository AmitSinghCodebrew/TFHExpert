//
//  UILabelExtensions.swift
//  FeedniExpert
//
//  Created by Sandeep Kumar on 19/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

extension UILabel {
    
    func setAttributedText(original: (text: String, font: UIFont, color: UIColor), toReplace: (text: String, font: UIFont, color: UIColor)...) {
        let originalAttributes = [NSAttributedString.Key.foregroundColor : original.color,
                                  NSAttributedString.Key.font: original.font]
        
        var toReplaceTexts = [NSMutableAttributedString]()

        toReplace.forEach {
            toReplaceTexts.append(NSMutableAttributedString.init(string: $0.text, attributes: [NSAttributedString.Key.foregroundColor : $0.color,
                                                                                               NSAttributedString.Key.font : $0.font]))
        }
        
        let mutableAttributedString = NSMutableAttributedString.init(string: original.text, attributes: originalAttributes)
        
        zip(toReplaceTexts, toReplace).forEach { (item) in
            if let rangeToReplace = original.text.range(of: item.1.text) {
                mutableAttributedString.replaceCharacters(in: NSRange.init(rangeToReplace, in: original.text), with: item.0)
            }
        }
        
        attributedText = mutableAttributedString
        
    }
    
}

