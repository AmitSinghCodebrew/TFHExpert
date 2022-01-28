//
//  ChatVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 03/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tableView: ChatTable! {
        didSet {
            tableView.registerXIBForHeaderFooter(ChatTimeHeaderView.identfier)
        }
    }
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblTyping: UILabel!

    
    public var thread: ChatThread?
    
    private var dataSource: TableDataSource<TimeStampProvider, MessageProvider, Message>?
    private var messages: [TimeStampProvider]?
    private var backendMessages = [Message]()
    private var timer: Timer?
    private var currentSeconds: Int?
    private var after: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewInit()
        initializeSocketListers()
        initialChatLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SocketIOManager.shared.connect { [weak self] in
            self?.readMessages()
        }
        tableView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        SocketIOManager.shared.changeTypingStatus(of: String(/thread?.from_user?.id), to: false)
    }

    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            timer?.invalidate()
            SocketIOManager.shared.disconnect()
            popVC()
        case 1: //Options
            alertBoxOKCancel(title: VCLiteral.END_CHAT.localized, message: VCLiteral.END_CHAT_MESSAGE.localized, tapped: { [weak self] in
                self?.endChatAPI()
            }, cancelTapped: nil)
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension ChatVC {
    public func initialChatLoad() {
        messages = []
        backendMessages = []
        dataSource?.updateAndReload(for: .MultipleSection(items: []), .FullReload)
        initialSetUp()
        getMessagesAPI()
    }
    
    private func initialSetUp() {
        lblTimer.text = nil
        lblName.text = /thread?.from_user?.name
        lblTyping.isHidden = true
        lblTyping.text = VCLiteral.TYPING.localized
        btnMore.setTitle(VCLiteral.END_CHAT.localized, for: .normal)
    }
    
    private func startTimer() {
        if currentSeconds == nil {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            self?.currentSeconds = /self?.currentSeconds + 1
            let hours = /self?.currentSeconds / 3600
            let minutes = (/self?.currentSeconds % 3600) / 60
            let seconds = (/self?.currentSeconds % 3600) % 60
            self?.lblTimer.text = "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        })
    }
    
    private func tableViewInit() {
        
        tableView.transform = CGAffineTransform.init(scaleX: 1, y: -1)
        
        if thread?.status == .inProgress {
            tableView.becomeFirstResponder()
            tableView.chatAccessory.thread = thread
            btnMore.isHidden = false
        } else {
            btnMore.isHidden = true
        }
        
        tableView.chatAccessory.sendAMessage = { [weak self] (sendAMessage) in
            switch sendAMessage {
            case .Text(let model):
                model.status = .SENT
                self?.insertANewMessage(model, image: nil)
            case .Image(let model, let image):
                self?.insertANewMessage(model, image: image)
                self?.uploadImageAPI(message: model, image: image, type: .image)
                self?.readMessages()
            case .Document(let model):
                self?.insertANewMessage(model, image: nil)
                self?.uploadImageAPI(message: model, image: nil, type: .pdf)
                self?.readMessages()
            case .Audio(let model):
                self?.insertANewMessage(model, image: nil)
                self?.uploadImageAPI(message: model, image: nil, type: .audio)
                self?.readMessages()
            }
        }
        
        dataSource = TableDataSource<TimeStampProvider, MessageProvider, Message>.init(.MultipleSection(items: messages ?? []), tableView)
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            view.transform = CGAffineTransform.init(scaleX: 1, y: -1)
            (view as? ChatTimeHeaderView)?.item = item
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            cell.contentView.transform = CGAffineTransform.init(scaleX: 1, y: -1)
            (cell as? SenderTxtCell)?.item = item
            (cell as? SenderImgCell)?.item = item
            (cell as? SenderImgCell)?.didTapUploadImageRetry = { [weak self] (message, image) in
                self?.tableView.reloadData()
                self?.uploadImageAPI(message: message, image: image, type: .image)
            }
            (cell as? SenderDocCell)?.item = item
            (cell as? SenderDocCell)?.didTapUploadDocRetry = { [weak self] (message, doc) in
                self?.tableView.reloadData()
                self?.uploadImageAPI(message: message, image: nil, type: .pdf)
            }
            (cell as? SenderAudioCell)?.item = item
            (cell as? SenderAudioCell)?.didPlayPause = { [weak self] (status) in
                self?.playPauseAudio(status: status, model: item, indexPath: indexPath)
            }
            (cell as? RecieverTxtCell)?.item = item
            (cell as? RecieverImgCell)?.item = item
            (cell as? RecieverDocCell)?.item = item
            (cell as? RecieverAudioCell)?.item = item
            (cell as? RecieverAudioCell)?.didPlayPause = { [weak self] (status) in
                self?.playPauseAudio(status: status, model: item, indexPath: indexPath)
            }
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getMessagesAPI()
            }
        }
        
        dataSource?.refreshProgrammatically()
    }
    
    private func uploadImageAPI(message: Message?, image: UIImage?, type: MediaTypeUpload) {
        EP_Home.uploadMedia(image: image ?? UIImage(), type: type, doc: message?.localDoc, localAudioPath: message?.localAudioPath).request(success: { [weak self] (responseData) in
            let response = (responseData as? ImageUploadData)
            message?.imageUrl = response?.image_name
            message?.sentAt = Date().timeIntervalSince1970 * 1000
            message?.status = .SENT
            if let index: Int = self?.backendMessages.firstIndex(where: {$0.messageId == message?.messageId}) {
                self?.backendMessages[index] = message!
            }
            self?.messages?.first?.items?.first(where: {$0.property?.model?.messageId == message?.messageId})?.uploadStatus = .UploadingFinished
            self?.messages?.first?.items?.first(where: {$0.property?.model?.messageId == message?.messageId})?.property?.model = message
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.messages ?? []), .FullReload)
            SocketIOManager.shared.sendMessage(message: message!)
        }) { [weak self] (error) in
            self?.messages?.first?.items?.first(where: {$0.property?.model?.messageId == message?.messageId})?.uploadStatus = .Error(error: /error)
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.messages ?? []), .FullReload)
        }
    }
    
    private func getMessagesAPI() {
        EP_Home.chatMessages(requestId: String(/thread?.id), after: after).request(success: { [weak self] (responseData) in
            let response = (responseData as? MessagesData)
            self?.after = response?.after
            if /self?.messages?.count == 0 {
                self?.backendMessages = response?.messages ?? []
                self?.currentSeconds = response?.currentTimer
                self?.startTimer()
                self?.messages = TimeStampProvider.getSectionalData((self?.backendMessages ?? []))
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.messages ?? []), .FullReload)
                SocketIOManager.shared.connect { [weak self] in
                    self?.readMessages()
                }
            } else {
                self?.backendMessages = (self?.backendMessages ?? []) + (response?.messages ?? [])
                self?.messages = TimeStampProvider.getSectionalData((self?.backendMessages ?? []))
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.messages ?? []), .FullReload)
            }
            self?.dataSource?.stopInfiniteLoading(self?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.sendFirstMessage()
        }) { [weak self] (error) in
            
        }
    }
    
    private func sendFirstMessage() {
        if backendMessages.count == 0 {
            let message = Message.init(nil, String.init(format: VCLiteral.CHAT_INITIAL_MESSAGE.localized, /thread?.from_user?.name?.capitalizingFirstLetter()), .TEXT, thread, nil)
            tableView.chatAccessory.localId = /tableView.chatAccessory.localId - 1
            SocketIOManager.shared.sendMessage(message: message)
            message.messageId = tableView.chatAccessory.localId
            insertANewMessage(message, image: nil)
        }
    }
    
    private func endChatAPI() {
        EP_Home.endChat(requestId: String(/thread?.id)).request(success: { [weak self] (response) in
            self?.popVC()
        }) { (_) in
            
        }
    }
    
    private func readMessages() {
        if let message = backendMessages.first(where: {/$0.senderId != /UserPreference.shared.data?.id}) {
            SocketIOManager.shared.readMessage(message: message)
        }
    }
    
    private func initializeSocketListers() {
        SocketIOManager.shared.didRecieveMessage = { [weak self] (message) in
            if /message.senderId == self?.thread?.from_user?.id && /self?.backendMessages.count != 0 {
                self?.insertANewMessage(message, image: nil)
            }
        }
        
        SocketIOManager.shared.didRequestCompleted = { [weak self] in
            self?.messages?.first?.items?.first?.property?.model?.status = .NOT_SENT
            self?.backendMessages.first?.status = .NOT_SENT
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.messages ?? []), .Reload(indexPaths: [IndexPath.init(row: 0, section: 0)], animation: .none))
            Toast.shared.showAlert(type: .apiFailure, message: VCLiteral.CANT_SEND_MESSAGE.localized)
        }
        
        SocketIOManager.shared.didReadMessageByOtherUser = { [weak self] (message) in
            if /message.senderId == self?.thread?.from_user?.id {
                self?.backendMessages.forEach({ $0.status = .SEEN })
                self?.messages?.first?.items?.forEach({ $0.property?.model?.status = .SEEN })
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.messages ?? []), .ReloadSectionAt(indexSet: IndexSet(integer: 0), animation: .none))
            }
        }
        
        SocketIOManager.shared.didDeliveredMessageByOtherUser = { [weak self] (message) in
            if /message.senderId == self?.thread?.from_user?.id {
                self?.backendMessages.forEach({ (msg) in
                    if (msg.status == .SEEN || msg.status == .NOT_SENT) {
                    } else {
                        msg.status = .DELIVERED
                    }
                })
                self?.messages?.first?.items?.forEach({ (provider) in
                    if (provider.property?.model?.status == .SEEN || provider.property?.model?.status == .NOT_SENT) {
                    } else {
                        provider.property?.model?.status = .DELIVERED
                    }
                })
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.messages ?? []), .ReloadSectionAt(indexSet: IndexSet(integer: 0), animation: .none))
            }
        }
        
        SocketIOManager.shared.didTypingStatusChanged = { [weak self] (isTyping, userID) in
            self?.lblTyping.isHidden = (String(/self?.thread?.from_user?.id) == userID) ? !isTyping : true
        }
    }
    
    private func insertANewMessage(_ message: Message, image: UIImage?) {
        backendMessages.insert(message, at: 0)
        let messageProvider = MessageProvider.init((/message.messageType?.getRelatedCellId(userID: /message.senderId), UITableView.automaticDimension, message), nil, nil)
        if let _ = image {
            messageProvider.uploadStatus = .Uploading
        }
        if let _ = message.localDoc {
            messageProvider.uploadStatus = .Uploading
        }
        messageProvider.localImage = image
        messages?.first?.items?.insert(messageProvider, at: 0)
        dataSource?.updateAndReload(for: .MultipleSection(items: messages ?? []), .AddRowsAt(indexPaths: [IndexPath.init(row: 0, section: 0)], animation: .bottom, moveToLastIndex: true))
    }
    
    private func playPauseAudio(status: SKAudioStatus?, model: MessageProvider?, indexPath: IndexPath) {
        switch status {
        
        case .Paused: //Pause Player
            pauseAllAudio()
        case .Playing: //Play Audio
            pauseAllAudio()
            guard let url = URL.init(string: Configuration.getValue(for: .APP_AUDIO) + /model?.property?.model?.imageUrl) else {
                return
            }
//            URL.init(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")! //Sample Audio
            SKAudioPlayer.shared.play(for: url, currentTime: /model?.property?.model?.audioInfo?.currentValue) { (streamingInfo) in
                streamingInfo.status = .Playing
                model?.property?.model?.audioInfo = streamingInfo
                let tempItems = self.dataSource?.getMultipleSectionItems()
                tempItems?[indexPath.section].items?[indexPath.row] = model!
                self.dataSource?.updateAndReload(for: .MultipleSection(items: tempItems ?? []), .None)
                (self.tableView.cellForRow(at: indexPath) as? SenderAudioCell)?.item = model
                (self.tableView.cellForRow(at: indexPath) as? RecieverAudioCell)?.item = model
            } _: { (isBuffering) in
                model?.property?.model?.audioInfo?.isBuffering = isBuffering
                let tempItems = self.dataSource?.getMultipleSectionItems()
                tempItems?[indexPath.section].items?[indexPath.row] = model!
                self.dataSource?.updateAndReload(for: .MultipleSection(items: tempItems ?? []), .None)
                (self.tableView.cellForRow(at: indexPath) as? SenderAudioCell)?.item = model
                (self.tableView.cellForRow(at: indexPath) as? RecieverAudioCell)?.item = model
            }
            
            SKAudioPlayer.shared.didFinishedAudio = { [weak self] in
                model?.property?.model?.audioInfo?.currentValue = 0
                self?.pauseAllAudio()
            }
        case .none:
            break
        }
    }
    
    private func pauseAllAudio() {
        let tempItems = dataSource?.getMultipleSectionItems()
        tempItems?.forEach({ (provider) in
            provider.items?.forEach({
                $0.property?.model?.audioInfo?.isBuffering = false
                $0.property?.model?.audioInfo?.status = .Paused
            })
        })
        SKAudioPlayer.shared.pause()
        dataSource?.updateAndReload(for: .MultipleSection(items: tempItems ?? []), .FullReload)
    }
}
