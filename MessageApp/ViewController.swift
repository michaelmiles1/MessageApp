//
//  ViewController.swift
//  MessageApp
//
//  Created by Michael Miles on 3/14/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var newMessageTextView: UITextView!
    @IBOutlet private weak var sendMessageContainerView: UIView!
    @IBOutlet private weak var messageCollectionView: UICollectionView!
    
    @IBOutlet weak var oldContainerViewBottomConstraint: NSLayoutConstraint!
    
    private var messageArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        setupCollectionView()
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
        // Q: Should we also close the keyboard when a message is sent? Other apps don't do this so I'll leave that out
        newMessageTextView.resignFirstResponder()
    }
    
    private func setupCollectionView() {
        messageCollectionView.delegate   = self
        messageCollectionView.dataSource = self
        if let flow = messageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        messageArray.append(newMessageTextView.text)
        newMessageTextView.text = "test"
        messageCollectionView.reloadData()
    }
    

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        messageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCollectionViewCell", for: indexPath) as! MessageCollectionViewCell
        let message = messageArray[indexPath.row]
        cell.messageTextLabel.text = message
        return cell
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

