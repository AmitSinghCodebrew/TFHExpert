//
//  NextButtonAccessory.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 11/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import Lottie

class NextButtonAccessory: UIView {
    
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var btnNext: SKButton!
    let animationView = AnimationView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK:- Block to check tap on Continue button
    var didTapContinue: (() -> Void)?
    
    //MARK:- for iPhoneX Spacing bottom
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
    }
    
    @IBAction func btnContinueAction(_ sender: Any) {
        didTapContinue?()
    }
    
    func startAnimation() {
        btnNext.isHidden = true
        lottieView.isHidden = false
        animationView.play()
    }
    
    func stopAnimation() {
        btnNext.isHidden = false
        lottieView.isHidden = true
        animationView.stop()
    }
    
    // Performs the initial setup.
    private func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        animationView.backgroundColor = UIColor.clear
        animationView.animation = Animation.named(LottieFiles.NextAccessory.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 2.0
        animationView.frame = lottieView.bounds
        lottieView.addSubview(animationView)
        lottieView.isHidden = true
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
}
