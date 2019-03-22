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
        
        setupDataSource()
        
        stopListeningToUser = stopListeningToUser ?? loadProfileData()
    }
    
    deinit {
        stopListeningToUser?()
    }
    
    func setupDataSource(){
        dataSource = TopicStubDataSource()
        
        favoriteTopicsCollection.dataSource = dataSource
        favoriteTopicsCollection.delegate = self
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
            self.render(with: user)
        }
    }
    
    func render(with user: User){
        self.bioLabel.text = user.bio
        self.nameLabel.text = user.name
        
        self.dataSource.topics = self.getTopics(from: user.favoriteTopics)
        self.favoriteTopicsCollection.reloadData()
        
        // If something else changes, don't reload the image.
        if let image = user.image {
            self.onImageLoaded(image: image)
        }
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    // The VC is the delegate because it knows about the collectionView's frame
    
    // Dynamically sizes the topic cells based on the screen size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.dataSource.getTopicSize(frameWidth: view.frame.width)
    }
    
    func onImageLoaded(image: UIImage) {
        profilePic.tintColor = UIColor.clear
        profilePic.setImage(image, for: .normal)
    }
    
    // Gets topics from the root topic store
    func getTopics(from topicIds: [String]) -> [Topic] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let topics = appDelegate.topicCollection.topics.filter { topicIds.contains($0.id) }
        return topics
    }
}
