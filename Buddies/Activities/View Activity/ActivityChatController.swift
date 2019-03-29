//
//  ActivityChatController.swift
//  Buddies
//
//  Created by Noah Allen on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar

class ActivityChatController: MessagesViewController {
    @IBOutlet weak var chatAreaView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var messageList: [Message] = []

    // Local data for rendering:
    private var activity: Activity?
    private var memberStatus: MemberStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = chatAreaView
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    // Call this to re-render with new data:
    func render(with activity: Activity?, memberStatus: MemberStatus?) {
        self.activity = activity
        self.memberStatus = memberStatus
        self.statusLabel?.text = memberStatus == .owner ? "You are this activity's owner." : "You are a member of this activity."
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: Message) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
}


extension ActivityChatController: MessagesDataSource,MessagesDisplayDelegate, MessagesLayoutDelegate {
    // MARK: - MessagesDataSource
    
    func currentSender() -> Sender {
        
        return Sender(id: "testid", displayName: "name")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
}

// MARK: - MessageInputBarDelegate

extension ActivityChatController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            
            if let str = component as? String {
                let message = Message(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}
