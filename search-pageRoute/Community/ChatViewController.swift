//
//  ChatViewController.swift
//  garden_app
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

// 1. Simple Model for our Messages
struct Message {
    let text: String
    let isSender: Bool
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    // Top Header
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerNameLabel: UILabel!
    
    // The Chat Area
    @IBOutlet weak var tableView: UITableView!
    
    // The Bottom Input Area
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var inputBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Data
    var user: User? // The person we are talking to
    
    // Dummy Data
    var messages: [Message] = [
        Message(text: "May I know about the plants you have? 🤗", isSender: true),
        Message(text: "Sureee I would love to tell lets meet at 7? 🤗", isSender: false),
        Message(text: "That sounds perfect! See you then.", isSender: true)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            print("✅ Step 4: Chat Screen received user: \(user.name)")
        } else {
            print("❌ Error: Chat Screen user is NIL!")
        }
        setupUI()
        setupKeyboardObservers()
        
        messageTextField.delegate = self
        tableView.keyboardDismissMode = .onDrag    }
    
    // MARK: - Setup & Styling 🎨
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        //tableView.allowsSelection = false // Disable clicking cells
        
        // 2. Setup Header Data (If user is passed)
        if let user = user {
            headerNameLabel.text = user.name
            let imageName = CommunityDataStore.shared.profileImageString(for: user.id)
                headerImageView.configureImage(with: imageName)
            
        }
        
        // 3. Styling (Corner Radius in Code as requested)
        headerImageView.layer.cornerRadius = headerImageView.frame.height / 2
        messageTextField.superview?.layer.cornerRadius = 18
    }
    
    // MARK: - TableView Logic 📝
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        // 1. Decide which cell to load
        let cellIdentifier = message.isSender ? "SenderCell" : "ReceiverCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatBubbleCell
        
        // 2. Set Text
        cell.messageLabel.text = message.text
        
        // 3. Apply Corner Radius
        cell.bubbleView.layer.cornerRadius = 16
        if message.isSender {
            cell.bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        } else {
            cell.bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        
        return cell
    }
    
    // MARK: - Keyboard Handling ⌨️
    // This moves the input bar up when keyboard opens
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            
            let bottomPadding = view.safeAreaInsets.bottom
                        self.inputBottomConstraint.constant = -(keyboardSize.height - bottomPadding)
                        
                        UIView.animate(withDuration: 0.3) {
                            self.view.layoutIfNeeded()
                        }
                        scrollToBottom()
                    }
                }
    
  @objc func keyboardWillHide(notification: NSNotification) {
       self.inputBottomConstraint.constant = 0
    
    UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
    }
}
    @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    func scrollToBottom() {
        if !messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Sending Logic 

        // This function runs when the user hits "Return" or "Send" on the keyboard
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            sendMessage()
            return true
        }

        func sendMessage() {
            // 1. Check if text exists and isn't just spaces
            guard let text = messageTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            // 2. Create the new message object (Me = isSender: true)
            let newMessage = Message(text: text, isSender: true)

            // 3. Add to our data source
            messages.append(newMessage)

            // 4. Insert the row into the TableView nicely (Animation)
            let newIndexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .right)
            
            // 5. Scroll to the new message
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)

            // 6. Clear the text field
            messageTextField.text = ""
        }
    
    
}
