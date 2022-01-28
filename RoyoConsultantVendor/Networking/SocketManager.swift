//
//  SocketManager.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 20/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//
//

import SocketIO

enum EventName: String {
    case sendMessage
    case messageFromServer
    case typing
    case broadcast
    case acknowledgeMessage
    case readMessage
    case deliveredMessage
    case sendlivelocation
}

class SocketIOManager {
    static let shared = SocketIOManager()

    private var manager = SocketManager.init(socketURL: URL.init(string: Configuration.getValue(for: .APP_SOCKET_BASE_PATH))!, config: [.log(true),
                                                                                                                                    .connectParams(["user_id" : "\(/UserPreference.shared.data?.id)",
                                                                                                                                                    "domain" : /UserPreference.shared.clientDetail?.domain]),
                                                                                                                                    .forceNew(true)])
    
    public var didRecieveMessage: ((_ message: Message) -> Void)?
    public var didRequestCompleted: (() -> Void)?
    public var didReadMessageByOtherUser: ((_ obj: Message) -> Void)?
    public var didDeliveredMessageByOtherUser: ((_ obj: Message) -> Void)?
    public var didTypingStatusChanged: ((_ isTyping: Bool, _ userID: String) -> Void)?
    private var didSocketConnected: (() -> Void)?

    private var isListening = false
    
    public func connect(_ success: (() -> Void)?) {
        
        didSocketConnected = success

        switch manager.defaultSocket.status {
        case .disconnected, .notConnected:
            manager = SocketManager.init(socketURL: URL.init(string: Configuration.getValue(for: .APP_SOCKET_BASE_PATH))!, config: [.log(true),
                                                                                                                                    .connectParams(["user_id" : "\(/UserPreference.shared.data?.id)",
                                                                                                                                                    "domain" : /UserPreference.shared.clientDetail?.domain]),
                                                                                                                                    .forceNew(true)])
            manager.defaultSocket.connect()
        case .connected, .connecting:
            didSocketConnected?()
            return
        }
        
        isListening ? () : setupListeners()
    }

    public func disconnect() {

        manager.defaultSocket.off(SocketClientEvent.disconnect.rawValue)
        manager.defaultSocket.off(SocketClientEvent.connect.rawValue)
        manager.defaultSocket.off(SocketClientEvent.error.rawValue)

        manager.defaultSocket.off(EventName.sendMessage.rawValue)
        manager.defaultSocket.off(EventName.messageFromServer.rawValue)
        manager.defaultSocket.off(EventName.typing.rawValue)
        manager.defaultSocket.off(EventName.broadcast.rawValue)
        manager.defaultSocket.off(EventName.acknowledgeMessage.rawValue)
        manager.defaultSocket.off(EventName.readMessage.rawValue)
        manager.defaultSocket.off(EventName.deliveredMessage.rawValue)

        manager.defaultSocket.disconnect()
        
        isListening = false

    }

    private func setupListeners() {
        
        isListening = true
        
        manager.defaultSocket.on(SocketClientEvent.disconnect.rawValue) { [weak self] (response, _) in
            debugPrint("👹👹👹👹👹👹👹👹👹👹 Socket Disconnected: \(response)")
            self?.disconnect()
        }

        manager.defaultSocket.on(SocketClientEvent.connect.rawValue) { [weak self] (response, _) in
            self?.didSocketConnected?()
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Socket Connnected: \(response)")
        }

        manager.defaultSocket.on(SocketClientEvent.error.rawValue) { [weak self] (response, socket) in
            debugPrint("👹👹👹👹👹👹👹👹👹👹 Socket Error: \(response)", socket)
            self?.disconnect()
        }

        manager.defaultSocket.on(EventName.messageFromServer.rawValue) { [weak self] (response, _) in
            debugPrint("🐦🐦🐦🐦🐦🐦🐦🐦🐦🐦 Chat Message Received: \(response)")
            guard let messageDict = response.first as? [String : Any] else {
                return
            }
            let model = Message.init(socketResponse: messageDict)
            self?.deliveredMessage(message: model)
            self?.didRecieveMessage?(model)
            if /UIApplication.topVC()?.isKind(of: ChatVC.self) && UIApplication.shared.applicationState == .active {
                self?.readMessage(message: model)
            }
        }

        manager.defaultSocket.on(EventName.readMessage.rawValue) { [weak self] (response, _) in
            guard let messageDict = response.first as? [String : Any] else {
                return
            }
            let model = Message.init(socketResponse: messageDict)
            self?.didReadMessageByOtherUser?(model)
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Chat Message read by other user: \(messageDict)")
        }
        
        manager.defaultSocket.on(EventName.deliveredMessage.rawValue) { [weak self] (response, _) in
            guard let messageDict = response.first as? [String : Any] else {
                return
            }
            let model = Message.init(socketResponse: messageDict)
            self?.didDeliveredMessageByOtherUser?(model)
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Chat Message delivered to other user: \(messageDict)")
        }
        
        manager.defaultSocket.on(EventName.typing.rawValue) { [weak self] (response, _) in
            guard let messageDict = response.first as? [String : Any] else {
                return
            }
            self?.didTypingStatusChanged?(/Bool(/(messageDict["isTyping"] as? String)), /(messageDict["senderId"] as? String))
            debugPrint("🤫🤫🤫🤫🤫🤫🤫🤫🤫🤫 Chat User is typing: \(messageDict)")
        }

        manager.defaultSocket.on(EventName.acknowledgeMessage.rawValue) { (response, _) in
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Chat Message Acknowledgement: \(response)")
        }
    }

    public func changeTypingStatus(of userID: String, to isTyping: Bool) {
        manager.defaultSocket.emitWithAck(EventName.typing.rawValue, ["senderId": String(/UserPreference.shared.data?.id),
                                                                      "receiverId": userID,
                                                                      "isTyping": String(isTyping)]).timingOut(after: 1.0) { (response) in
                                                                        debugPrint("😍😍😍😍😍😍😍😍😍😍 Typing status updated: \(response)")
                                                                      }
    }
    
    func sendMessage(message: Message) {
        var dict = JSONHelper<Message>().toDictionary(model: message) as? [String : Any]
        dict?["sentAt"] = Int64(Date().timeIntervalSince1970 * 1000)
        dict?.removeValue(forKey: "messageId")
        dict?.removeValue(forKey: "user")
        
        manager.defaultSocket.emitWithAck(EventName.sendMessage.rawValue, dict ?? [:]).timingOut(after: 1.0) { [weak self] (response) in
            let responseDict = (response as? [[String : Any]])?.first
            if /(responseDict?["status"] as? String) == "REQUEST_COMPLETED" {
                self?.didRequestCompleted?()
            }
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Chat Message sent: \(response)")
        }
    }
    
    public func readMessage(message: Message?) {
        let dict = ["messageId" : /message?.messageId,
                    "senderId": /message?.receiverId,
                    "receiverId": /message?.senderId]
        
        manager.defaultSocket.emitWithAck(EventName.readMessage.rawValue, dict).timingOut(after: 1.0) { (response) in
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Chat Message Read from this side: \(response)")
        }
    }
    
    public func sendLocation(request: Requests?) {
        
        let loc = LocationManager.shared.locationData

        let dict = ["request_id" : /request?.id,
                    "lat": "\(/loc.latitude)",
                    "long": "\(/loc.longitude)",
                    "senderId": /request?.to_user?.id,
                    "receiverId": /request?.from_user?.id] as [String : Any]
        manager.defaultSocket.emitWithAck(EventName.sendlivelocation.rawValue, dict).timingOut(after: 1.0) { (response) in
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Location sent from this side: \(response)")
        }
    }
    
    private func deliveredMessage(message: Message?) {
        let dict = ["messageId" : /message?.messageId,
                    "senderId": /message?.receiverId,
                    "receiverId": /message?.senderId]
        manager.defaultSocket.emitWithAck(EventName.deliveredMessage.rawValue, dict).timingOut(after: 1.0) { (response) in
            debugPrint("😍😍😍😍😍😍😍😍😍😍 Chat Message Delivered from this side: \(response)")
        }
    }
}
