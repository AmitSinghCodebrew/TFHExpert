//
//  FeedsData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 19/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class FeedsData: Codable {
    var feed: Feed?
    var feeds: [Feed]?
    var after: String?
    var before: String?
    var per_page: Int?
}

final class Feed: Codable {
    var title: String?
    var description: String?
    var type: FeedType?
    var user_id: Int?
    var image: String?
    var id: Int?
    var created_at: String?
    var user_data: User?
    var favorite: Int?
    var views: Int?
    var is_favorite: Bool?
}
