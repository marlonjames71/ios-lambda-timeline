//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        tableView.tableFooterView = UIView()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }

    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {

        let commentOptionsActionSheet = UIAlertController(title: "What kind of comment would you like to leave?", message: "Choose from one of the following:", preferredStyle: .actionSheet)

        let textCommentAction = UIAlertAction(title: "Text Comment", style: .default) { _ in

            let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)

            var commentTextField: UITextField?

            alert.addTextField { (textField) in
                textField.placeholder = "Comment:"
                textField.autocapitalizationType = .sentences
                commentTextField = textField
            }

            let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in

                guard let commentText = commentTextField?.text else { return }

                self.postController.addComment(with: commentText, to: self.post) {
                    self.tableView.reloadData()
                }
//                self.postController.addComment(with: commentText, to: self.post!)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alert.addAction(addCommentAction)
            alert.addAction(cancelAction)

            self.present(alert, animated: true, completion: nil)
        }

        let audioCommentAction = UIAlertAction(title: "Audio Comment", style: .default) { _ in
            self.performSegue(withIdentifier: "showModalRecordSegue", sender: self)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        [textCommentAction, audioCommentAction, cancelAction].forEach { commentOptionsActionSheet.addAction($0) }
        present(commentOptionsActionSheet, animated: true, completion: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModalRecordSegue" {
            guard let navController = segue.destination as? UINavigationController,
                let recordVC = navController.children.first as? RecordAudioViewController else { return }
            recordVC.postController = postController
            recordVC.post = post
            recordVC.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        let comment = post?.comments[indexPath.row]
        
        cell.comment = comment
        
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}

extension ImagePostDetailTableViewController: RecordAudioViewControllerDelegate {
    func didAddAudioComment(recordAudioViewController: RecordAudioViewController, addedComment: Bool) {
        if addedComment {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
