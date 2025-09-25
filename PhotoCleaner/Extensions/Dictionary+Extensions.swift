//
//  Dictionry+Extension.swift
//  FreePlay
//
//  Created by Ne Spesha on 11/04/2025.
//

import Foundation

extension Dictionary {
    
    var prettyPrinted: NSString? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]),
            let prettyPrintedString = String(data: data, encoding:.utf8)
        else { return nil }
        
        return (prettyPrintedString as NSString)
    }
    
    var localizedValue: String? {
        
        guard
            let self = self as? [String: AnyHashable]
        else { return nil }
        
        let languageCode = Locale.current.language.languageCode?.identifier
        let collatorIdentifier = Locale.current.collatorIdentifier
        var key = collatorIdentifier ?? "en"
        
        var value = self[key]
        if value == nil {
            key = languageCode ?? "en"
            value = self[key]
        }
        
        if value == nil {
            key = "en"
            value = self[key]
        }
        
        return value as? String
    }
}
