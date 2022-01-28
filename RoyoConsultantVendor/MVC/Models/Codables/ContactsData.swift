//
//  QuestionsData.swift
//  RoyoConsultantExpert
//
//  Created by Sandeep Kumar on 12/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class ContactsData: Codable {
    
    var contacts: [Contacts]?
}

final class Contacts: Codable {
    var id: Int?
    var name: String?
    var phone_numbers: [Numbers]?
}

final class Numbers: Codable {
    var phone: String?
    var type_label: String?
    
}
