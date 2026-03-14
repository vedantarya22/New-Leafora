//
//  CommentsViewController.swift
//  Leafora
//

import UIKit

class CommentsViewController: UIViewController,
                               UITableViewDelegate,
                               UITableViewDataSource,
                               UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var inputBottomConstraint: NSLayoutConstraint!

    // MARK: - Data
    var post: Post!                      // set by CommunityViewController before pushing
    private var comments: [Comment] = [] // local copy — fetched from backend

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard post != nil else {
            print("❌ ERROR: No Post passed to CommentsViewController")
            return
        }

        tableView.delegate   = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()

        commentTextField.delegate = self
        setupKeyboardObservers()

        // ── Load comments from backend ──────────────────────────────────────
        loadComments()
    }

    // MARK: - Load Comments
    private func loadComments() {
        PostRepository.shared.fetchComments(postId: post.id) { [weak self] fetched in
            self?.comments = fetched
            self?.tableView.reloadData()

            // Scroll to bottom if there are existing comments
            if let count = self?.comments.count, count > 0 {
                let last = IndexPath(row: count - 1, section: 0)
                self?.tableView.scrollToRow(at: last, at: .bottom, animated: false)
            }
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CommentsCell", for: indexPath
        ) as! CommentsCell

        let comment = comments[indexPath.row]

        // author is a PostAuthor populated by backend
        cell.usernameLabel.text = comment.author?.username ?? "Unknown"
        cell.commentLabel.text  = comment.text
        cell.timeLabel.text     = comment.displayTimestamp   // uses createdAt → timeAgo

        return cell
    }

    // MARK: - Actions
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func postTapped(_ sender: UIButton) {
        sendComment()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        return true
    }

    // MARK: - Send Comment
    func sendComment() {
        guard let text = commentTextField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty
        else { return }

        // Clear field immediately for snappy UX
        commentTextField.text = ""

        PostRepository.shared.addComment(postId: post.id, text: text) { [weak self] comment in
            guard let self = self else { return }

            if let comment = comment {
                // Append the server-returned comment (has real id, createdAt, author)
                self.comments.append(comment)
                let last = IndexPath(row: self.comments.count - 1, section: 0)
                self.tableView.insertRows(at: [last], with: .automatic)
                self.tableView.scrollToRow(at: last, at: .bottom, animated: true)
            } else {
                print("⚠️ addComment failed — backend did not return a Comment")
            }
        }
    }

    // MARK: - Keyboard
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                        as? NSValue)?.cgRectValue {
            let offset = -(frame.height - view.safeAreaInsets.bottom)
            inputBottomConstraint.constant = offset
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        inputBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
