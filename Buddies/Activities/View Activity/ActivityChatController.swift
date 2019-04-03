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
import Firebase
class ActivityChatController: MessagesViewController {
    @IBOutlet weak var chatAreaView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var messageList: [Message] = []

    // Local data for rendering:
    var activity: Activity?
    var memberStatus: MemberStatus?
    var user: LoggedInUser?
    var userCanceler: Canceler?
    var registration: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view = chatAreaView
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.tintColor = Theme.theme
        
        
        userCanceler = DataAccessor.instance.useLoggedInUser { user in
            self.user = user
        }
    }
    
    deinit {
        userCanceler?()
        registration?.remove()
    }
    
    func loadMessageList() {
        registration?.remove()
        
        if let activity = activity {
            let actRef = Firestore.firestore().collection("activities").document(activity.activityId)
            
            registration = actRef.collection("chat").addSnapshotListener { (snap, err) in
                guard let snap = snap else { return }
                
                self.messageList = (snap.documents.compactMap { doc in
                    let data = doc.data()
                    let sender = Sender(id: data["sender"] as! String, displayName: "Someone Else")
                    
                    if data["type"] as! String != "message" {
                        return nil
                    }
                    
                    return Message(text: data["message"] as! String, sender: sender, messageId: doc.documentID, date: (data["date_sent"] as! Timestamp).dateValue())
                }).sorted { $0.sentDate < $1.sentDate }
                
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
        
        
    }
    
    func insertMessage(msg: Message){
        if let activity = activity {

            let actRef = Firestore.firestore().collection("activities").document(activity.activityId)
            
            actRef.collection("chat").addDocument(data: [
                "date_sent": Date(),
                "message": msg.content,
                "sender": user?.uid ?? "Me",
                "type" : "message"
            ])
            
            
        }
        
    }

    
}



extension ActivityChatController: MessagesDataSource, MessagesLayoutDelegate {
    // MARK: - MessagesDataSource
    
    func currentSender() -> Sender {
        
        return Sender(id: user?.uid ?? "id", displayName: user?.name ?? "Me")
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
        
            let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
            insertMessage(msg: message)
        
        inputBar.inputTextView.text = String()

        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ActivityChatController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Theme.theme : Theme.lightGray
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        //avatarView.set(avatar: avatar)
        
        let userID = message.sender.id
        
        //let avatarImage =
        
        let avi = Avatar(image: nil, initials: String(message.sender.displayName.prefix(1)))
        
        avatarView.set(avatar:avi)
    }
    
}
