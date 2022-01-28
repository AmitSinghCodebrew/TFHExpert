//
//  ADDImagesModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 08/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AddMedia {
    var url: Any?
    var isUploading = false
    var type: MediaTypeUpload = .image
    var doc: Document?
    
    
    init(_ _url: Any?, _ _type: MediaTypeUpload) {
        type = _type
        url = _url
    }
    
    init(_ _url: Any?, _ _type: MediaTypeUpload, _ _doc: Document?) {
        type = _type
        url = _url
        doc = _doc
    }
}

class MediaObj: Codable {
    var image: String?
    var type: MediaTypeUpload?
    
    init(_ _media: String?, _ _type: MediaTypeUpload?) {
        image = _media
        type = _type
    }
    
    class func getArrayToUp(items: [AddMedia]?) -> [MediaObj] {
        var uploadItems = [MediaObj]()
        items?.forEach({ (media) in
            if let url = media.url as? String {
                uploadItems.append(MediaObj.init(url, media.type))
            }
        })
        return uploadItems
    }
}


class GenderOption: SKGenericPickerModelProtocol {
    
    typealias ModelType = FilterOption

    var title: String?
    
    var model: FilterOption?
    
    required init(_ _title: String?, _ _model: FilterOption?) {
        title = _title
        model = _model
    }
}
