//
//  SenderAudioCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 14/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit
import AVFoundation

class SenderAudioCell: BaseChatCell {
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public var didPlayPause: (( _ status: SKAudioStatus?) -> Void)?

    override func setupData() {
        super.setupData()
        let obj = item?.property?.model
        
        viewBack.roundCorners(with: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 16.0)
        lblType.text = "   \(VCLiteral.AUDIO.localized)   "
        lblType.cornerRadius = 6.0
        lblType.clipsToBounds = true
        btnStatus.isHidden = obj?.status?.statusImage == nil
        btnStatus.setImage(obj?.status?.statusImage, for: .normal)
        btnStatus.tintColor = obj?.status?.tintColor
        slider.setThumbImage(#imageLiteral(resourceName: "ic_slider_head"), for: .normal)
        slider.setThumbImage(#imageLiteral(resourceName: "ic_slider_head"), for: .highlighted)
        slider.minimumValue = 0
        slider.maximumValue = /obj?.audioInfo?.maxValue
        slider.isContinuous = true
        slider.value = /obj?.audioInfo?.currentValue
        slider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        slider.isUserInteractionEnabled = obj?.audioInfo?.status == .Playing
        btnPlayPause.setImage(obj?.audioInfo?.status == .Playing ? #imageLiteral(resourceName: "ic_pause") : #imageLiteral(resourceName: "ic_play_mini"), for: .normal)
        activityIndicator.transform = CGAffineTransform.init(scaleX: 0.75, y: 0.75)
        activityIndicator.isHidden = !(/obj?.audioInfo?.isBuffering)
        /obj?.audioInfo?.isBuffering ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    @IBAction func btnPlayAction(_ sender: UIButton) {
        let status = item?.property?.model?.audioInfo?.status ?? .Paused
        didPlayPause?(status == .Playing ? .Paused : .Playing)
    }
    
    @objc private func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        SKAudioPlayer.shared.seekAudio(for: playbackSlider.value)
    }
}
