//
//  JSONHelper.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 12/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

class JSONHelper<T: Codable> {
    
    init() {
        
    }
    
    /* MARK:- Convert any Data to Specific model
     Use case: Used for api responses to map into models */
    func getCodableModel(data: Data) -> T? {
        let model = try? JSONDecoder().decode(T.self, from: data)
        return model
    }
    
    /* MARK:- Convert Any type (which could be dictionary or NSArray or NSDictionary)
     Use case: Used for notification response and socket response to map into models */
    func getCodableModel(data: Any) -> T? {
        
        guard let objData = try? JSONSerialization.data(withJSONObject: data, options: .sortedKeys) else {
            return nil
        }
        return getCodableModel(data: objData)
        
    }
    
    /* MARK:- Convert models to Data
     Use case: Used to save data object in Userdefaults */
    func getData(model: T) -> Data? {
        guard let data: Data = try? JSONEncoder().encode(model) else {
            return nil
        }
        return data
    }
    
    /* MARK:- Convert model to dictionary */
    func toDictionary(model: T) -> Any? {
        do {
            guard let data = getData(model: model) else {
                throw NSError(domain: "Can't convert model to data", code: 1, userInfo: nil)
            }
            
            let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return dict
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    /* MARK:- Convert model to JSON String
     Use case: To send input to backend api's as objects input */
    func toJSONString(model: T) -> String? {
        var json: String?
        do {
            guard let data = getData(model: model) else {
                throw NSError(domain: "Can't convert model to data", code: 1, userInfo: nil)
            }
            json = String(data: data, encoding: String.Encoding.utf8)
        } catch {
            debugPrint(error.localizedDescription)
        }
        return json
    }
}
