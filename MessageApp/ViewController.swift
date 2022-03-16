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
        
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
        if #available(iOS 15.0, *) {
            applyiOS15KeyboardLayout()
        } else {
            applyOldiOSKeyboardLayout()
        }
    }
    
    @objc private func closeKeyboard() {
        newMessageTextView.resignFirstResponder()
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
    private func applyOldiOSKeyboardLayout() {
        oldContainerViewBottomConstraint.constant = UIApplication.shared.windows[0].safeAreaInsets.bottom
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func showKeyboard(notification: Notification) {
        let notifInfo = notification.userInfo
        if let endRect = notifInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            var offset = view.bounds.size.height - endRect.origin.y
            if offset == 0.0 {
                offset = UIApplication.shared.windows[0].safeAreaInsets.bottom
            }
            let duration = notifInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.5
            UIView.animate(withDuration: duration) { [weak self] in
                guard let welf = self else { return }
                welf.oldContainerViewBottomConstraint.constant = offset
                welf.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func hideKeyboard(notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.5
        UIView.animate(withDuration: duration) { [weak self] in
            guard let welf = self else { return }
            welf.oldContainerViewBottomConstraint.constant = UIApplication.shared.windows[0].safeAreaInsets.bottom
            welf.view.layoutIfNeeded()
        }
    }
}

