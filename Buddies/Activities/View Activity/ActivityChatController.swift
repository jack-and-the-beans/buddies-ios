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
    
    var messageList: [Message] = [Message(text: "test", sender: Sender(id: "asdf", displayName: "adsaf"), messageId: "testID", date: Date())]

    // Local data for rendering:
    var activity: Activity?
    var memberStatus: MemberStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view = chatAreaView
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    /*
    // Call this to re-render with new data:
    func render(with activity: Activity?, memberStatus: MemberStatus?) {


    }*/
    
    
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
                messageList.append(message)
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}
