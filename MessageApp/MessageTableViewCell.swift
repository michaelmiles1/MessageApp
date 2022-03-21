//
//  MessageTableViewCell.swift
//  MessageApp
//
//  Created by Michael Miles on 3/16/22.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    @IBOutlet private weak var messageTextLabel: UILabel!
    @IBOutlet private weak var messageContainerView: UIView!
    
    @IBOutlet private weak var messageBoxWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingViewContraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageBoxWidthConstraint.constant = UIScreen.main.bounds.width/0.8
    }
    
    func setupWithMessage(message: MessageModel) {
        messageTextLabel.text = message.text
        switch message.type {
        case .sent:
            leadingViewConstraint.isActive = false
            trailingViewContraint.isActive = true
            messageContainerView.backgroundColor = .systemBlue
        case .received:
            leadingViewConstraint.isActive = true
            trailingViewContraint.isActive = false
            messageContainerView.backgroundColor = .systemGray5
        }
    }
}
