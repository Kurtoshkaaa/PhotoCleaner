//
//  Realm+Extensions.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import Foundation
import RealmSwift

extension Realm {
    
    static var current: Realm {

            var realmConfig = Realm.Configuration.defaultConfiguration
            if
                let bundleVersionString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
                let bundleVersion = UInt64(bundleVersionString)
            {
                realmConfig.schemaVersion = bundleVersion
            }
            
            realmConfig.migrationBlock = { migration, oldSchemaVersion in
                
            }
            
            realmConfig.shouldCompactOnLaunch = { totalBytes, usedBytes in
                let limitBytes = 100 * 1024 * 1024
                let value = (totalBytes > limitBytes) && (Double(usedBytes) / Double(totalBytes)) < 0.5
                return value
            }
            
            realmConfig.objectTypes = [
                Settings.self
            ]
            
            return try! Realm(configuration: realmConfig)
    }
    
    func safeWrite(
        _ block: (() -> Void),
        withoutNotifying notificationTokens: [NotificationToken]? = nil
    ) throws {
        if isInWriteTransaction {
            block()
        } else {
            if let value = notificationTokens {
                try write(withoutNotifying: value, block)
            } else {
                try write(block)
            }
        }
    }
    
    func safeWrite(
        _ block: (() -> Void),
        withCompletion completion: (() -> Void),
        withoutNotifying notificationTokens: [NotificationToken]? = nil
    ) throws {
        if isInWriteTransaction {
            block()
            completion()
        } else {
            if let value = notificationTokens {
                try write(withoutNotifying: value, block)
            } else {
                try write(block)
            }
            completion()
        }
    }
}
