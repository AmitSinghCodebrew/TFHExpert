//
//  UIViewControllerExtensions.swift
//  AE
//
//  Created by MAC_MINI_6 on 19/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import AVKit
import MapKit
import SafariServices

enum Storyboard<T : UIViewController>: String {
    case LoginSignUp
    case TabBar
    case Other
    case PopUp
    
    func instantiateVC() -> T {
        let sb = UIStoryboard(name: self.rawValue, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
        return vc
    }
}

extension UINavigationController {
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
    func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = viewController
        setViewControllers(vcs, animated: animated)
    }
}

extension UIViewController {
    
    func share(items: [Any], sourceView: UIView?) {
        let activityVC = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sourceView
        presentVC(activityVC)
    }
    
    func presentSafariVC(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = ColorAsset.appTint.color
        presentVC(vc)
    }
    
    func pushVC(_ vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    func popVC(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func presentVC(_ vc: UIViewController) {
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func replaceLastVCInStack(with viewcontroller: UIViewController) {
        var vcArray = navigationController?.viewControllers
        viewcontroller.transition(from: (vcArray?.last)!, to: viewcontroller, duration: 0.5, options: UIView.AnimationOptions.autoreverse, animations: {
            
        }) { (completed) in
            vcArray!.removeLast()
            vcArray!.append(viewcontroller)
            self.navigationController?.setViewControllers(vcArray!, animated: true)
        }
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func topMostVC() -> UIViewController {
        let vc = UIApplication.topVC()
        guard let topVC = vc else {
            return UIViewController()
        }
        return topVC
    }
    
    func playVideo(_ url: URL?) {
        guard let localOrServerURL = url else {
            return
        }
        let player = AVPlayer(url: localOrServerURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func popTo<T: UIViewController>(toControllerType: T.Type) {
        if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers {
                if currentViewController .isKind(of: toControllerType) {
                    self.navigationController?.popToViewController(currentViewController, animated: true)
                    break
                }
            }
        }
    }
    
    func popVCs(viewsToPop: Int, animated: Bool = true) {
        if /navigationController?.viewControllers.count > viewsToPop {
            guard let vc = navigationController?.viewControllers[/navigationController?.viewControllers.count - viewsToPop - 1] else { return }
            navigationController?.popToViewController(vc, animated: animated)
        }
    }
    
    func actionSheet(for actions: [String], title: String?, message: String?, view: UIView?, tapped: ((_ actionString: String?) -> Void)?) {
        let actionSheetController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actions.forEach {
            
            let action = UIAlertAction(title: $0, style: .default, handler: { (action) in
                tapped?(action.title)
            })
            actionSheetController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: VCLiteral.CANCEL.localized, style: .cancel, handler: { (_) in
            
        })
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = view
        actionSheetController.popoverPresentationController?.permittedArrowDirections = .up
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func alertWithDesc(desc: String?) {
        //    let messageString = NSMutableAttributedString.init(string: /desc, attributes: [NSAttributedString.Key.font : Fonts.SFProTextMedium.ofSize(14),
        //                                                                                      NSAttributedString.Key.foregroundColor: Color.textBlack90.value])
        
        let alert = UIAlertController(title: "", message: desc, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: VCLiteral.CANCEL.localized, style: .cancel, handler: { (_) in
        }))
        //    alert.setValue(messageString, forKey: "attributedMessage")
        present(alert, animated: true, completion: nil)
    }
    
    func alertBoxOKCancel(title: String?, message: String?, tapped: (() -> Void)?, cancelTapped: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: VCLiteral.CANCEL.localized, style: .cancel, handler: { (_) in
            cancelTapped?()
        }))
        alert.addAction(UIAlertAction.init(title: VCLiteral.OK.localized, style: .default, handler: { (_) in
            tapped?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertBox(title: String?, message: String?, btn1: String?, btn2: String?, tapped1: (() -> Void)?, tapped2: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: /btn1, style: .default, handler: { (_) in
            tapped1?()
        }))
        alert.addAction(UIAlertAction.init(title: /btn2, style: .default, handler: { (_) in
            tapped2?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Present PopUp
    func presentPopUp(_ destVC: UIViewController) {
        addChild(destVC)
        destVC.view.frame = view.frame
        view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
    
    //MARK:- PopUps start
    func startPopUpWithAnimation() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    //MARK:- PopUp End
    func removePopUp() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in
            if finished{
                self.view.removeFromSuperview()
            }
        })
    }
}
