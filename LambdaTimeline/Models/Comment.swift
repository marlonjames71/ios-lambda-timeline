//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let audioURLKey = "audioURL"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    
    var text: String?
    var audioURL: URL?
    let author: Author
    let timestamp: Date
    
    init(text: String?, audioURL: URL?, author: Author, timestamp: Date = Date()) {
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
            guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }

        if let text = dictionary[Comment.textKey] as? String {
            self.text = text
        }

        if let audioURL = dictionary[Comment.audioURLKey] as? String {
            self.audioURL = URL(string: audioURL)
        }

        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text as Any,
                Comment.audioURLKey: audioURL?.absoluteString as Any,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
