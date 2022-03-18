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
    @IBOutlet private weak var messageTableView: UITableView!
    
    @IBOutlet weak var oldContainerViewBottomConstraint: NSLayoutConstraint!
    
    private var messageArray: [MessageModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboard()
        setupTableView()
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
    
    private func setupTableView() {
        messageTableView.delegate           = self
        messageTableView.dataSource         = self
        messageTableView.rowHeight          = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 75
        messageTableView.transform          = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let newMessage = MessageModel(text: newMessageTextView.text, type: .sent)
        addMessageToTable(newMessage)
        newMessageTextView.text = "test"
    }
    
    @IBAction func receiveButtonPressed(_ sender: Any) {
        let newMessage = MessageModel(text: "Here's your new message!", type: .received)
        addMessageToTable(newMessage)
    }
    
    private func addMessageToTable(_ msg: MessageModel) {
        messageArray.insert(msg, at: 0)
        messageTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageArray[indexPath.row]
        switch message.type {
        case .sent:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SentMessageTableViewCell", for: indexPath) as! SentMessageTableViewCell
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.messageTextLabel.text = message.text
            return cell
        case .received:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedMessageTableViewCell", for: indexPath) as! ReceivedMessageTableViewCell
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.messageTextLabel.text = message.text
            return cell
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

struct MessageModel {
    var text: String
    var type: MessageType
    
    enum MessageType {
        case sent
        case received
    }
}
