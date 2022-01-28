//
//  Gradient+UIButton+UIView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/03/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint: CGPoint {
        return points.startPoint
    }
    
    var endPoint: CGPoint {
        return points.endPoint
    }
    
    var points: GradientPoints {
        switch self {
        case .topRightBottomLeft:
            return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
        case .topLeftBottomRight:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1, y: 1))
        case .horizontal:
            return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .vertical:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
        }
    }
}

extension UIView {
    
    func applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) {
        self.layer.sublayers?.removeAll(where: {$0.isKind(of: CAGradientLayer.self)})
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.cornerRadius = /self.cornerRadius
        self.layer.masksToBounds = true
        self.layer.insertSublayer(gradient, at: 0)
        
        (self as? UIButton)?.imageView?.layer.zPosition = 1
        (self as? UIButton)?.titleLabel?.layer.zPosition = 1
    }
    
    func applyGradientBorder(borderWidth: CGFloat, colors: [UIColor], orientation: GradientOrientation) {
        let gradient = CAGradientLayer()
        gradient.frame =  self.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.cornerRadius = /self.cornerRadius
        self.layer.masksToBounds = true

        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth
        shape.path = UIBezierPath.init(roundedRect: bounds.insetBy(dx: borderWidth, dy: borderWidth), cornerRadius: (self.cornerRadius)).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.borderWidth = 0
        self.layer.insertSublayer(gradient, at: 0)
    }
}

class GradientView: UIView {
    
    var borderWidthValue: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.first(where: {$0.isKind(of: CAGradientLayer.self)})?.frame = bounds
    }
    
    private func setGradient() {
        if UserPreference.shared.isGradientViews {
            self.applyGradient(withColours: UserPreference.shared.gradientColors, gradientOrientation: .horizontal)
        }
    }
    
    func isGradienHidden(isSelected: Bool) {
        if UserPreference.shared.isGradientViews == false {
            return
        }
        if self.borderWidth != 0 {
            borderWidthValue = self.borderWidth
        }
        self.layer.sublayers?.first(where: {$0.isKind(of: CAGradientLayer.self)})?.isHidden = !isSelected
        if UserPreference.shared.isGradientViews {
            self.borderWidth = isSelected ? 0 : borderWidthValue
        }
    }
}

class GradientBorderView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if UserPreference.shared.isGradientViews {
            self.applyGradientBorder(borderWidth: borderWidth, colors: UserPreference.shared.gradientColors, orientation: .horizontal)
        }
    }
}
