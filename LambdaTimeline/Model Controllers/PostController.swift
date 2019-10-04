//
//  PostController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PostController {
    
    func createPost(with description: String, audioURL: URL? = nil, ofType mediaType: MediaType, mediaData: Data, ratio: CGFloat? = nil, completion: @escaping (Bool) -> Void = { _ in }) {
        
        guard let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser) else { return }
        
        store(mediaData: mediaData, mediaType: mediaType) { (mediaURL) in
            
            guard let mediaURL = mediaURL else { completion(false); return }
            
            let imagePost = Post(mediaURL: mediaURL, ratio: ratio, author: author, description: description)
            
            self.postsRef.childByAutoId().setValue(imagePost.dictionaryRepresentation) { (error, ref) in
                if let error = error {
                    NSLog("Error posting image post: \(error)")
                    completion(false)
                }
        
                completion(true)
            }
        }
    }
    
    func addComment(with text: String?, to post: Post, completion: @escaping () -> Void) {
        
        guard let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser) else {
                completion()
                return
        }

        let comment = Comment(text: text, audioURL: nil, author: author)
        post.comments.append(comment)
        
        savePostToFirebase(post) { _ in
            completion()
        }
    }

    func addAudioComment(with data: Data, to post: Post, completion: @escaping () -> Void) {

        guard let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser) else {
                completion()
                return
        }

        store(mediaData: data, mediaType: .image) { (url) in
            let comment = Comment(text: nil, audioURL: url, author: author)

            post.comments.append(comment)

            self.savePostToFirebase(post) { _ in
                completion()
            }
        }
    }

    func observePosts(completion: @escaping (Error?) -> Void) {
        
        postsRef.observe(.value, with: { (snapshot) in
            
            guard let postDictionaries = snapshot.value as? [String: [String: Any]] else { return }
            
            var posts: [Post] = []
            
            for (key, value) in postDictionaries {
                guard let post = Post(dictionary: value, id: key) else { continue }
                posts.append(post)
            }
            
            self.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })

            completion(nil)
        }) { (error) in
            NSLog("Error fetching posts: \(error)")
        }
    }
    
    func savePostToFirebase(_ post: Post, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let postID = post.id else { return }
        
        let ref = postsRef.child(postID)

        ref.setValue(post.dictionaryRepresentation) { (error, _) in
            if let error = error {
                NSLog("Error saving post: \(error)")
                completion(error)
            }
            completion(nil)
        }
    }

    private func store(mediaData: Data, mediaType: MediaType, completion: @escaping (URL?) -> Void) {
        
        let mediaID = UUID().uuidString
        
        let mediaRef = storageRef.child(mediaType.rawValue).child(mediaID)
        
        let uploadTask = mediaRef.putData(mediaData, metadata: nil) { (metadata, error) in
            if let error = error {
                NSLog("Error storing media data: \(error)")
                completion(nil)
                return
            }
            
            if metadata == nil {
                NSLog("No metadata returned from upload task.")
                completion(nil)
                return
            }
            
            mediaRef.downloadURL(completion: { (url, error) in
                
                if let error = error {
                    NSLog("Error getting download url of media: \(error)")
                }
                
                guard let url = url else {
                    NSLog("Download url is nil. Unable to create a Media object")
                    
                    completion(nil)
                    return
                }
                completion(url)
            })
        }
        
        uploadTask.resume()
    }
    
    var posts: [Post] = []
    let currentUser = Auth.auth().currentUser
    let postsRef = Database.database().reference().child("posts")
    
    let storageRef = Storage.storage().reference()
    
    
}
