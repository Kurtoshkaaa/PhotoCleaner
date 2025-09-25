//
//  Settings.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import RealmSwift

fileprivate var SettingsID: String = "Settings"

final class Settings: Object, ObjectKeyIdentifiable {
    
    /*
     MARK: -
     */
    
    static var current: Settings {
        get {
            
            let realm = Realm.current
            var settings = realm.object(
                ofType: Settings.self,
                forPrimaryKey: SettingsID
            )
            
            if settings == nil {
                try? realm.safeWrite {
                    settings = Settings(value: ["id": SettingsID])
                    realm.add(settings!)
                }
            }
            
            return settings!
        }
    }
    
    /*
     MARK: - Persisted
     */
    
    @Persisted(primaryKey: true)
    var id: String = SettingsID
    
    @Persisted
    var isOnboardingCompleted: Bool = false
}
