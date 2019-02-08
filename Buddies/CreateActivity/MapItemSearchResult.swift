//
//  MapItemSearchResult.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/8/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import MapKit

class MapItemSearchResult : SearchTextFieldItem{

    public var mapData: MKLocalSearchCompletion?
    
    override init(title: String) {
        super.init(title: title)
    }
    
}
