//
//  ProfileVCTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 3/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class OtherProfileVCTests: XCTestCase {
    
    var vc: OtherProfileVC? = OtherProfileVC()
    
    var profilePic = UIButton()
    var bioLabel = UILabel()
    var nameLabel = UILabel()
    var activityTable = UITableView()
    var favoriteTopicsCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: UICollectionViewLayout())

    override func setUp() {
        
        vc?.dataSource = TopicStubDataSource()
        favoriteTopicsCollection.dataSource = vc?.dataSource

        vc?.profilePic = profilePic
        vc?.bioLabel = bioLabel
        vc?.nameLabel = nameLabel
        vc?.activityTable = activityTable
        vc?.favoriteTopicsCollection = favoriteTopicsCollection
        
    }
    
    func testRender() {
        
        let user = OtherUser(uid: "id",
                             imageUrl: "lolurl",
                             imageVersion: 0,
                             dateJoined: Date(),
                             name: "name",
                             bio: "bio",
                             favoriteTopics: [])
        
        vc?.render(with: user)
        
        XCTAssert(vc?.bioLabel.text == user.bio, "Bio is set correctly")
        XCTAssert(vc?.nameLabel.text == user.name, "User's name is set correctly")
        XCTAssert(vc?.profilePic.image(for: .normal) == nil, "No image should be loaded, since no valid url given")
    }


    func testOnImageLoad(){
        let img = UIImage()
        vc?.profilePic.setImage(nil, for: .normal)
        XCTAssert(vc?.profilePic.image(for: .normal) == nil, "Initially in this test, Profile pic is nil")
        vc?.onImageLoaded(image: img)
        XCTAssert(vc?.profilePic.image(for: .normal) == img, "Image is set through ProfileVC's onImageLoaded")
    }
    
    func testSetupDataSource(){
        vc?.favoriteTopicsCollection.dataSource = nil
        vc?.favoriteTopicsCollection.delegate = nil
        vc?.setupDataSource()
        
        XCTAssert(vc?.favoriteTopicsCollection.dataSource != nil, "DataSource for favorite collection is set")
        XCTAssert(vc?.favoriteTopicsCollection.delegate as? OtherProfileVC == vc, "DataSource for favorite collection is set")
        XCTAssert(vc?.dataSource != nil, "VC's datasource is set")
    }

}
