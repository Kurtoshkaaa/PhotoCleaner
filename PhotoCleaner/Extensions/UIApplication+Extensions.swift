//
//  UIApplication+Extensions.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//

import UIKit

#if canImport(UIKit)
extension UIApplication {
    
    static var rootViewController: UIViewController? {
        return shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
    
    var topViewController: UIViewController? {
        // 1. Берём keyWindow, корректно для iOS 13+
        let keyWindow = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        // 2. Рекурсивно ищем верхушку иерархии
        func top(from base: UIViewController?) -> UIViewController? {
            if let nav = base as? UINavigationController {
                return top(from: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                return top(from: tab.selectedViewController)
            }
            if let presented = base?.presentedViewController {
                return top(from: presented)
            }
            return base
        }

        return top(from: keyWindow?.rootViewController)
    }
    
    func share(viewController: UIViewController) {
        if
            let activityVC = viewController as? UIActivityViewController,
            let popover = activityVC.popoverPresentationController
        {
            if let rootView = topViewController?.view {
                popover.sourceView = rootView
                popover.sourceRect = CGRect(
                    x: rootView.bounds.midX,
                    y: rootView.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
        }
        
        DispatchQueue.main.async {
            guard
                let root = self.topViewController
            else { return }
            
            let presenter = root.presentedViewController ?? root
            presenter.present(
                viewController,
                animated: true
            )
        }
    }
    
}
#endif
