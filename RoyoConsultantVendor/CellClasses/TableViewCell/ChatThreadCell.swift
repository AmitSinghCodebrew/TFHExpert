//
//  ChatThreadCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ChatThreadCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<ChatThread>
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewCount: UIView!
    @IBOutlet weak var lblUnreadCount: UILabel!
    @IBOutlet weak var widthUnreadCount: NSLayoutConstraint!
    
    var item: DefaultCellModel<ChatThread>? {
        didSet {
            let obj = item?.property?.model
            lblName.text = "\(/obj?.from_user?.name) (\(/obj?.status?.title.localized.lowercased()))"
            imgView.setImageNuke(/obj?.from_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            switch obj?.last_message?.messageType ?? .TEXT {
            case .TEXT:
                lblMessage.text = (/obj?.last_message?.message).prefix(20).description
            case .IMAGE:
                lblMessage.text = VCLiteral.PHOTO.localized
            case .PDF:
                lblMessage.text = VCLiteral.DOC_MESSAGE.localized
            case .AUDIO:
                lblMessage.text = VCLiteral.AUDIO.localized
            }
            let timeStamp = Date.init(timeIntervalSince1970: /obj?.last_message?.sentAt / 1000.0).getChatTimeStamp()
            lblTime.text = String.init(format: VCLiteral.CHAT_THREAD_TIME.localized, timeStamp)
            
            lblUnreadCount.text = "\(/obj?.unReadCount)"
            viewCount.isHidden = /obj?.unReadCount == 0
            if "\(/obj?.unReadCount)".count > 1 {
                widthUnreadCount.constant = /"\(/obj?.unReadCount)".widthOfString(usingFont: Fonts.CamptonBook.ofSize(10)) + 12
            } else {
                widthUnreadCount.constant = 16.0
            }
        }
    }
}
