//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

enum MediaType: String {
    case image
    case video
}

class Post {

    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let description: String
    let timestamp: Date
    var comments: [Comment]
    var id: String?
    var ratio: CGFloat?

    var title: String? {
        return comments.first?.text
    }

    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let description = "description"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    
    init(mediaURL: URL, mediaType: MediaType, ratio: CGFloat? = nil, author: Author, description: String, timestamp: Date = Date()) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = .image
        self.author = author
        self.description = description
        self.comments = []
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let descriptionDict = dictionary[Post.description] as? String,
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval else { return nil }

        let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]]
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.description = descriptionDict
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries?.compactMap({ Comment(dictionary: $0) }) ?? []
        self.id = id
    }
    
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
                Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                Post.authorKey: author.dictionaryRepresentation,
                Post.description: description,
                Post.timestampKey: timestamp.timeIntervalSince1970]
        
        guard let ratio = self.ratio else { return dict }
        
        dict[Post.ratioKey] = ratio
        
        return dict
    }

}
