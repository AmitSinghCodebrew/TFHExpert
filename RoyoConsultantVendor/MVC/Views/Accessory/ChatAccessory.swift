//
//  ChatAccessory.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 21/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import SZTextView
import Lottie

class ChatTable: UITableView {
    lazy var chatAccessory: ChatAccessory = {
        let rect = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: 64)
        let inputAccessory = ChatAccessory(frame: rect)
        return inputAccessory
    }()
        
    override var inputAccessoryView: UIView? {
        return chatAccessory
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        keyboardDismissMode = .interactive
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.contentInset.top = keyboardHeight
            if keyboardHeight > 64 {
                scrollToTop()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.contentInset.top = keyboardHeight
        }
    }
}

enum SendMessageType {
    case Text(model: Message)
    case Image(model: Message, image: UIImage?)
    case Document(model: Message)
    case Audio(model: Message)
}

class ChatAccessory: UIView {
    @IBOutlet weak var btnSend: RTLSupportedButton!
    @IBOutlet weak var btnAttach: RTLSupportedButton!
    @IBOutlet weak var tfMessage: SZTextView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var viewAudio: UIView!
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSlideToCancel: UILabel!
    @IBOutlet weak var lottieView: UIView!
    
    var thread: ChatThread?
    var sendAMessage: ((_ message: SendMessageType) -> Void)?
    private var mediaPicker = SKMediaPicker.init(type: .ImageAndDocs)
    public var localId = -1
    private let pulsator = Pulsator()
    private var originalPoint: CGPoint = CGPoint.zero
    private var originalPointSlideText: CGPoint = CGPoint.zero
    private let animationView = AnimationView.init()
    private var recordingStatus = RecordingStatus.Idle

    var timer: Timer?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK:- for iPhoneX Spacing bottom
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Attachment
            tfMessage.resignFirstResponder()
            mediaPicker.presentPicker({ [weak self] (image) in
                let message = Message.init(nil, nil, .IMAGE, self?.thread, nil)
                self?.localId = /self?.localId - 1
                self?.sendAMessage?(.Image(model: message, image: image))
            }, { (url, data, image) in
                //Video
            }, { [weak self] (docs) in
                let message = Message.init(nil, nil, .PDF, self?.thread, nil)
                self?.localId = /self?.localId - 1
                message.localDoc = docs?.first
                message.imageUrl = docs?.first?.fileName
                self?.sendAMessage?(.Document(model: message))
            })
        case 1: //Send
            if /tfMessage.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                let message = Message.init(nil, tfMessage.text.trimmingCharacters(in: .whitespacesAndNewlines), .TEXT, thread, nil)
                localId = localId - 1
                SocketIOManager.shared.sendMessage(message: message)
                message.messageId = localId
                sendAMessage?(.Text(model: message))
                tfMessage.text = nil
                #if HealthCarePrashantExpert
                btnSend.setImage(#imageLiteral(resourceName: "ic_next"), for: .normal)
                #else
                btnSend.setImage(/tfMessage.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? #imageLiteral(resourceName: "ic_mic") : #imageLiteral(resourceName: "ic_next"), for: .normal)
                #endif
            }
        default:
            break
        }
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
        // to dynamically increase height of text view
        // http://ticketmastermobilestudio.com/blog/translating-autoresizing-masks-into-constraints
        //if textView.translatesAutoresizingMaskIntoConstraints = true then height will not increase automatically
        // translatesAutoresizingMaskIntoConstraints default = true
        tfMessage.delegate = self
       
        #if HealthCarePrashantExpert
        viewAudio.isHidden = true
        lottieView.isHidden = true
        btnSend.setImage(#imageLiteral(resourceName: "ic_next"), for: .normal)
        #else
        let longTapGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapAction(_:)))
        let swipeLeftGesture = UIPanGestureRecognizer.init(target: self, action: #selector(swipeLeftAction(_:)))
        longTapGesture.delegate = self
        swipeLeftGesture.delegate = self
        btnSend.addGestureRecognizer(longTapGesture)
        btnSend.addGestureRecognizer(swipeLeftGesture)
        pulsator.numPulse = 5
        pulsator.radius = 45
        pulsator.position = CGPoint(x: btnSend.bounds.width / 2, y: btnSend.bounds.height / 2)
        pulsator.backgroundColor = ColorAsset.appTint.color.cgColor
        viewAudio.isHidden = true

        animationView.backgroundColor = UIColor.clear
        animationView.animation = Animation.named(LottieFiles.DeleteAudio.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFit
        animationView.frame = lottieView.bounds
        lottieView.addSubview(animationView)
        lottieView.backgroundColor = .clear
        lottieView.isHidden = true
        btnSend.setImage(#imageLiteral(resourceName: "ic_mic"), for: .normal)
        #endif
    }
    
    @objc private func swipeLeftAction(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: btnSend)
        
        if gesture.state == .began {
            originalPoint = CGPoint.init(x: btnSend.center.x, y: btnSend.center.y)
            originalPointSlideText = CGPoint.init(x: lblSlideToCancel.center.x, y: lblSlideToCancel.center.y)
        }
        
        if velocity.x > 0 {
            print("panning right")
        } else {
            print("panning left")
            let translation = gesture.translation(in: window)
            switch gesture.state {
            case .began, .changed:
                btnSend.center = CGPoint(x: btnSend.center.x + translation.x, y: btnSend.center.y)
                lblSlideToCancel.center = CGPoint.init(x: lblSlideToCancel.center.x + translation.x, y: lblSlideToCancel.center.y)
                gesture.setTranslation(CGPoint.zero, in: self)
                if lblSlideToCancel.center.x <= UIScreen.main.bounds.midX - 48 {
                    gesture.state = .ended
                    pulsator.stop()
                    btnSend.isHidden = true
                    lottieView.isHidden = false
                    recordingStatus = .Canceled
                    animationView.play { [weak self] (completed) in
                        self?.lottieView.isHidden = true
                        self?.animationView.stop()
                        self?.btnSend.isHidden = false
                        SKAudioRecorder.shared.finishRecording(fileURLGet: nil)
                    }
                } else {
                    recordingStatus = .Recording
                }
            case .ended:
                btnSend.center = originalPoint
                lblSlideToCancel.center = originalPointSlideText
                viewAudio.layoutSubviews()
                viewAudio.isHidden = true
                viewMessage.isHidden = false
            default:
                break
            }
        }
    }
    
    @objc private func longTapAction(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began: //StartAudioRecordinng
            SKAudioRecorder.shared.record(fileName: String(Date().timeIntervalSince1970) + "_audio") { [weak self] (status) in
                switch status {
                case .Granted:
                    break
                case .NotAuthorized:
                    break
                case .RecordingStarted:
                    self?.btnSend.layer.insertSublayer((self?.pulsator)!, at: 0)
                    self?.pulsator.start()
                    self?.viewAudio.isHidden = false
                    self?.viewMessage.isHidden = true
                case .Error(let description):
                    UIApplication.topVC()?.alertBoxOKCancel(title: AlertType.apiFailure.title, message: description, tapped: {
                        
                    }, cancelTapped: nil)
                }
            }

        case .ended: //StopAudioRecording
            if recordingStatus != .Canceled {
                recordingStatus = .Finished
            }
            SKAudioRecorder.shared.finishRecording { [weak self] (fileURL) in
                if self?.recordingStatus == .Finished {
                    let message = Message.init(nil, nil, .AUDIO, self?.thread, nil)
                    self?.localId = /self?.localId - 1
                    message.localAudioPath = fileURL
                    message.imageUrl = fileURL
                    self?.sendAMessage?(.Audio(model: message))
                }
            }
            pulsator.stop()
            pulsator.removeFromSuperlayer()
            viewAudio.isHidden = true
            viewMessage.isHidden = false
        default: break
        }
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
}

//MARK:-UITextViewDelegate
extension ChatAccessory: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        #if HealthCarePrashantExpert
        btnSend.setImage(#imageLiteral(resourceName: "ic_next"), for: .normal)
        #else
        btnSend.setImage(/textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? #imageLiteral(resourceName: "ic_mic") : #imageLiteral(resourceName: "ic_next"), for: .normal)
        #endif
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        SocketIOManager.shared.changeTypingStatus(of: String(/thread?.from_user?.id), to: true)
        self.timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            SocketIOManager.shared.changeTypingStatus(of: String(/self?.thread?.from_user?.id), to: false)
            self?.timer?.invalidate()
        })
        return true
    }

}

//MARK:- UIGestureRecognizerDelegate
extension ChatAccessory: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
