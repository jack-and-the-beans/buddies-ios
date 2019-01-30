/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

struct Topic {
  
    var name: String
    var image: UIImage
    var selected: Bool
  
    init(name: String, image: UIImage, selected: Bool = false) {
        self.name = name
        self.image = image
        self.selected = selected
    }
  
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String, let selected = dictionary["selected"] as? Bool, let photo = dictionary["image"] as? String,
            let image = UIImage(named: photo) else {
            return nil
        }
        self.init(name: name, image: image, selected: Bool(selected))
    }

    static func allTopics() -> [Topic] {
        var topics = [Topic]()
        guard let URL = Bundle.main.url(forResource: "Topics", withExtension: "plist"),
            let photosFromPlist = NSArray(contentsOf: URL) as? [[String:Any]] else {
            return topics
        }
        for dictionary in photosFromPlist {
            if let topic = Topic(dictionary: dictionary) {
                topics.append(topic)
            }
        }
        return topics
    }
  
}
