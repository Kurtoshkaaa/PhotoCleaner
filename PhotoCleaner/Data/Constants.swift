//
//  Constansts.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import CoreGraphics
import Foundation
import UIKit

public var SizeFactor: CGFloat {
    if let screen = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first(where: { $0.activationState == .foregroundActive })?
        .screen
    {
        return screen.bounds.width / 375.0
    }

    if let screen = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first?
        .screen
    {
        return screen.bounds.width / 375.0
    }

    if IsPreview {
        return 1.0
    }

    return 1.0
}

let IsPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

let AppID: String = ""

enum CustomError: Error {
    case custom(String)
}

let StartUpdating = NSNotification.Name(rawValue: "StartUpdating")
let FinishUpdating = NSNotification.Name(rawValue: "FinishUpdating")
