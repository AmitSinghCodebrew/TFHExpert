//
//  UIViewIBInsPectables.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit


extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension UIView{
    
    func roundCorners(with CACornerMask: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [CACornerMask]
    }
    
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension UIView {
  
  // In order to create computed properties for extensions, we need a key to
  // store and access the stored property
  fileprivate struct AssociatedObjectKeys {
    static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
  }
  
  fileprivate typealias Action = (() -> Void)?
  
  // Set our computed property type to a closure
  fileprivate var tapGestureRecognizerAction: Action? {
    set {
      if let newValue = newValue {
        // Computed properties get stored as associated objects
        objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
      }
    }
    get {
      let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
      return tapGestureRecognizerActionInstance
    }
  }
  
  // This is the meat of the sauce, here we create the tap gesture recognizer and
  // store the closure the user passed to us in the associated object we declared above
  public func addTapGestureRecognizer(action: (() -> Void)?) {
    self.isUserInteractionEnabled = true
    self.tapGestureRecognizerAction = action
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
    self.addGestureRecognizer(tapGestureRecognizer)
  }
  
  // Every time the user taps on the UIImageView, this function gets called,
  // which triggers the closure we stored
  @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
    if let action = self.tapGestureRecognizerAction {
      action?()
    } else {
      print("no action")
    }
  }
  
}
