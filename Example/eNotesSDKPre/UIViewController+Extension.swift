//
//  UIViewController+Extension.swift
//  eNotesSDKTest
//
//  Created by Smiacter on 2018/10/19.
//  Copyright © 2018 eNotes. All rights reserved.
//

extension UIViewController {
    
    /// return top viewcontroller 
    static func current() -> UIViewController? {
        
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        let currentVC = getFrom(rootVC: rootVC)
        
        return currentVC
    }
    
    static func getFrom(rootVC: UIViewController) -> UIViewController? {
        var root = rootVC
        var controller: UIViewController?
        
        if (root.presentedViewController != nil) {
            root = root.presentedViewController!
        }
        
        if root.isKind(of: UITabBarController.self) {
            let tabVC = root as! UITabBarController
            controller = getFrom(rootVC: tabVC.selectedViewController!)
        } else if root.isKind(of: UINavigationController.self) {
            let navVC = root as! UINavigationController
            controller = getFrom(rootVC: navVC.visibleViewController!)
        } else {
            controller = root
        }
        
        return controller
    }
}
