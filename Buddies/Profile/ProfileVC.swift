//
//  ProfileVC.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var profilePic: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteTopicsCollection: UICollectionView!
    
    var user: User?
    
    var dataSource: TopicStubDataSource!
    
    var stopListeningToUser: Canceler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        favoriteTopicsCollection.register(
            UINib.init(nibName: "ActivityTopicCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "topic_cell"
        )
        
        dataSource = TopicStubDataSource()
        
        favoriteTopicsCollection.dataSource = dataSource
        favoriteTopicsCollection.delegate = self
        
        stopListeningToUser = stopListeningToUser ?? loadProfileData()
        
    }
    
    deinit {
        stopListeningToUser?()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }
    
    func loadProfileData(storageManger: StorageManager = StorageManager.shared,
                          dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        return dataAccess.useLoggedInUser { user in
            guard let user = user else { return }
            
            self.user = user
            
            self.bioLabel.text = user.bio
            self.nameLabel.text = user.name
            
            self.dataSource.topics = self.getTopics(from: user.favoriteTopics)
            self.favoriteTopicsCollection.reloadData()
            
            // If something else changes, don't reload the image.
            if let image = user.image {
                self.onImageLoaded(image: image)
            }
        }
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    // The VC is the delegate because it knows about the collectionView's frame
    
    // Dynamically sizes the topic cells based on the screen size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin = 20
        let collectionWidth = self.view.frame.width - CGFloat(margin * 2)
        
        let height = CGFloat(40)
        if (self.dataSource.topics.count > 4) {
            let base = collectionWidth / 2
            return CGSize(width: base, height: height)
        } else {
            let cellWidth = collectionWidth / 2 - 10
            return CGSize(width: cellWidth, height: height)
        }
        
    }
    
    func onImageLoaded(image: UIImage) {
        profilePic.tintColor = UIColor.clear
        profilePic.setImage(image, for: .normal)
    }
    
    // Gets topics from the root topic store
    func getTopics(from topicIds: [String]) -> [Topic] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let topics = appDelegate.topicCollection.topics
        return topics.filter { topicIds.contains($0.id) }
    }

}
