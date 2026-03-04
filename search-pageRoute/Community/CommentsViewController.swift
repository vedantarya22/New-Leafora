//
//  CommentsViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var inputBottomConstraint: NSLayoutConstraint! //for keyboard to move along with input text field
    
    // MARK: - Data
    var post: Post! // call the data from user poist dat from datastore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        if post == nil {
                print("❌ ERROR: No Post data was passed to Comments Screen!")
                return
            }
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup Keyboard
        commentTextField.delegate = self
        setupKeyboardObservers()
        
        // Hide extra empty lines in table
        tableView.tableFooterView = UIView()
    }

    // MARK: - TableView Logic
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        let comment = post.comments[indexPath.row]
        
        cell.usernameLabel.text = comment.username
        cell.timeLabel.text = comment.timeAgo
        cell.commentLabel.text = comment.text
        
        return cell
    }
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTapped(_ sender: UIButton) {
        sendComment()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        return true
    }
    
    func sendComment() {
        guard let text = commentTextField.text, !text.isEmpty else { return }
        
        let newComment = Comment(
            id: UUID(),
            username: UserSession.shared.currentUser?.username ?? "Anonymous",
            text: text,
            timeAgo: "Just now"
        )
        
        // Write to the shared source of truth
        PostRepository.shared.addComment(to: post.id, comment: newComment)
        
        // Refresh local copy from the repository
        if let freshPost = PostRepository.shared.getPost(id: post.id) {
            post = freshPost
        }
        
        // Update Table
        tableView.reloadData()
        
        // Scroll to bottom
        if post.comments.count > 0 {
            let indexPath = IndexPath(row: post.comments.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
        // Clear Input
        commentTextField.text = ""
    }
    
    // MARK: - Keyboard Handling (The Slide Up Fix)
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Tap background to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Move up
            let height = -(keyboardSize.height - view.safeAreaInsets.bottom)
            inputBottomConstraint.constant = height
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // Move down
        inputBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


