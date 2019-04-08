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
    var userList: [User] = []

    // Local data for rendering:
    var activity: Activity?
    var memberStatus: MemberStatus?
    var user: LoggedInUser?
    var userCanceler: Canceler?
    var registration: ListenerRegistration?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true
        messageInputBar.tintColor = Theme.theme
        
        userCanceler = DataAccessor.instance.useLoggedInUser { user in
            self.user = user
        }
        
        loadMessageList()
        messageList = messageList.sorted { $0.sentDate < $1.sentDate }
        messagesCollectionView.reloadData()
        messageInputBar.inputTextView.resignFirstResponder()
        messagesCollectionView.scrollToBottom(animated: true)
        
    }
    
    deinit {
        userCanceler?()
        registration?.remove()
    }
    
    func tapUser(_ uid: String) {
        if let userProfile = BuddiesStoryboard.OtherProfile.viewController(withID: "otherProfile") as? OtherProfileVC {
            userProfile.userId = uid
            self.navigationController?.pushViewController(userProfile, animated: true)
        }
    }
    
    func getUserName(id:String) -> String{
        
        var name = ""
        for user in userList{
            if user.uid == id{
                name = user.name
            }
        }
        return name
    }
    
    func getAvatarImage(id:String) -> UIImage?{
        
        for user in userList{
            if user.uid == id{
                return user.image
            }
        }
        return nil
    }
    
    //Redacts message sent by banned users, no effect if not sent by banned user
    func redactMessages(){
        
        for msg in messageList {
            
            let msgSenderID = msg.sender.id
            
            if activity?.getMemberStatus(of: msgSenderID) == .banned {
                msg.kind = MessageKind.text("This user has been removed.")
            }
            
        }
        
        
        
    }
    

    func loadMessageList() {
        registration?.remove()
        
        if let activity = activity {
            let actRef = Firestore.firestore().collection("activities").document(activity.activityId)
            
            registration = actRef.collection("chat").addSnapshotListener { (snap, err) in
                guard let snap = snap else { return }
                
                self.messageList = (snap.documents.compactMap { doc in
                    let data = doc.data()
                    
                    let id = data["sender"] as! String
                    
                    let sender = Sender(id: id , displayName: self.getUserName(id: id))
                    
                    //if message from system
                    if data["type"] as! String != "message" {
                        let systemSender = Sender(id: "system", displayName: "")
                        let content =  NSAttributedString(string: data["message"] as! String, attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 14)])
                        
                        return Message(text: content, sender: systemSender, messageId: doc.documentID, date: (data["date_sent"] as! Timestamp).dateValue())
                    }
                    
                    return Message(text: data["message"] as! String, sender: sender, messageId: doc.documentID, date: (data["date_sent"] as! Timestamp).dateValue())
                    
                }).sorted { $0.sentDate < $1.sentDate }
                
                self.redactMessages()
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

// MARK: - MessagesDataSource
extension ActivityChatController: MessagesDataSource {
  
    
    func currentSender() -> Sender {
        
        return Sender(id: user?.uid ?? "id", displayName: user?.name ?? "Me")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if message.sender.id == "system"{
            return nil
        }else{
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: message.sentDate)
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        }
        
    }
    
}

// MARK: - MessageInputBarDelegate

extension ActivityChatController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
        
        insertMessage(msg: message)
        loadMessageList()
        messageList = messageList.sorted { $0.sentDate < $1.sentDate }
        inputBar.inputTextView.text = String()
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

// MARK: - MessagesDisplayDelegate
extension ActivityChatController: MessagesDisplayDelegate {
    
    
    // MARK: - Helpers
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].sender == messageList[indexPath.section - 1].sender
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].sender == messageList[indexPath.section + 1].sender
    }
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    // MARK: - All Messages
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if message.sender.id == "system"{
            return UIColor.clear
        }else
        {
             return isFromCurrentSender(message: message) ? Theme.theme : Theme.lightGray
        }
        
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        //hide tail if from system
        if message.sender.id == "system"{
            return MessageStyle.bubble
        }else{
            let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            
            
            return .bubbleTail(tail, .curved)
        }
    }
    
    
    
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.isHidden = false
        
        //hide avatar if from system
        if message.sender.id == "system"{
            avatarView.isHidden = true
        }else{
            let userID = message.sender.id
            
            let avatarImage = getAvatarImage(id: userID)
            
            let avi = Avatar(image: avatarImage, initials: String(message.sender.displayName.prefix(1)))
            
            avatarView.set(avatar:avi)
        }
        
      
    }
    
}

// MARK: - MessagesLayoutDelegate
extension ActivityChatController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (37.5) : 0
        }
    }
    
    
    
}



// MARK: - MessageCellDelegate
extension ActivityChatController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        
        //get index path from cell
        if let indexPath = messagesCollectionView.indexPath(for: cell){
            
            let msg = messageForItem(at: indexPath, in: messagesCollectionView)
            
            let userID = msg.sender.id
            
            if activity?.getMemberStatus(of: userID) != .banned {
                 tapUser(userID)
            }

            
        }
        
       
        
    }
    
}

