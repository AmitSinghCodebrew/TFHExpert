//
//  ChatModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 03/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

import UIKit

class TimeStampProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = MessageProvider
    
    typealias HeaderModelType = Any
    
    typealias FooterModelType = TimeModel
    
    var headerProperty: (identifier: String?, height: CGFloat?, model: Any?)?
    
    var footerProperty: (identifier: String?, height: CGFloat?, model: TimeModel?)?
    
    var items: [MessageProvider]?
    
    
    required init(_ _header: (identifier: String?, height: CGFloat?, model: Any?)?, _ _footer: (identifier: String?, height: CGFloat?, model: TimeModel?)?, _ _items: [MessageProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getSectionalData(_ messages: [Message]?) -> [TimeStampProvider] {
        var items = [TimeStampProvider]()
    
        let groupedDict = Dictionary.init(grouping: messages ?? []) { (message) -> DateComponents in
            let date = Date.init(timeIntervalSince1970: /message.sentAt / 1000.0)
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
            return dateComponents
        }
        let keyPairs = Array(groupedDict.keys)
        let valuePairs = Array(groupedDict.values)
        
        zip(keyPairs, valuePairs).forEach { (zipPair) in
            var messageProvider = [MessageProvider]()
            
            zipPair.1.forEach({
                let messgeProvider = MessageProvider.init((/$0.messageType?.getRelatedCellId(userID: /$0.user?.id), UITableView.automaticDimension, $0), nil, nil)
                messageProvider.append(messgeProvider)
            })
            items.append(TimeStampProvider.init(nil, (ChatTimeHeaderView.identfier, 48.0, TimeModel.init(Calendar.current.date(from: zipPair.0))), messageProvider))
        }
        
        if items.count == 0 {
            items = [TimeStampProvider.init(nil, (ChatTimeHeaderView.identfier, 48.0, TimeModel.init(Date())), [])]
        }
        
        return items.sorted{ ($0.footerProperty?.model?.date)! < ($1.footerProperty?.model?.date)! }
    }
}


class MessageProvider: CellModelProvider {
    
    typealias CellModelType = Message

    var property: (identifier: String, height: CGFloat, model: Message?)?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
        
    var localImage: UIImage?
    var uploadStatus: UploadStatus = .Default
    
    required init(_ _property: (identifier: String, height: CGFloat, model: Message?)?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}

class TimeModel {
    var date: Date?
    
    init(_ _date: Date?) {
        date = _date
    }
}

enum UploadStatus {
    case Error(error: String)
    case Uploading
    case UploadingFinished
    case Default
}
