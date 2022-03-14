//
//  ViewController.swift
//  MessageApp
//
//  Created by Michael Miles on 3/14/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var newMessageTextView: UITextView!
    @IBOutlet private weak var sendMessageContainerView: UIView!
    
    @IBOutlet weak var oldContainerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            applyiOS15KeyboardLayout()
        } else {
            applyOldiOSKeyboardLayout()
        }
    }


}

// iOS 15 keyboard layout
@available(iOS 15.0, *)
extension ViewController {
    private func applyiOS15KeyboardLayout() {
        oldContainerViewBottomConstraint.isActive = false
        sendMessageContainerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }
}

// Older iOS keyboard layout
extension ViewController {
    private var bottomSafeAreaHeight: CGFloat {
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        return window.frame.maxY - safeFrame.maxY
    }
    
    private func applyOldiOSKeyboardLayout() {
        oldContainerViewBottomConstraint.constant = bottomSafeAreaHeight
        NotificationCenter.default.addObserver(self, selector: #selector(respondToKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func respondToKeyboard(notification: Notification) {
        let notifInfo = notification.userInfo
        if let endRect = notifInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            var offset = view.bounds.size.height - endRect.origin.y
            if offset == 0.0 {
                offset = bottomSafeAreaHeight
            }
            let duration = notifInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.5
            UIView.animate(withDuration: duration) { [weak self] in
                guard let welf = self else { return }
                welf.oldContainerViewBottomConstraint.constant = offset
                welf.view.layoutIfNeeded()
            }
        }
    }
}

