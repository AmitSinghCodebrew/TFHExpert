//
//  WaterIntakeData.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 23/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class WaterIntakeData: Codable {
    var limit: Double?
    var today_intake: Double?
    var total_achieved_goal: Double?
}
