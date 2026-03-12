//
//  ChatViewController.swift
//  garden_app
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - Sender (who sent the message)
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

// MARK: - Message Model (updated to conform to MessageType)
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

// MARK: - ChatViewController
class ChatViewController: MessagesViewController {

    // MARK: - Data
    var user: User?  // The person we are chatting with

    // Current logged-in user (me)
    let mySender = Sender(senderId: "me", displayName: "Me")

    // Lazy: built once we know the `user` property
    var otherSender: Sender {
        Sender(senderId: user?.id ?? "other", displayName: user?.name ?? "User")
    }


    var messages: [Message] = []
    
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ App theme
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        
        // Make the messages collection view transparent so the gradient shows through
        messagesCollectionView.backgroundColor = .clear

        if let user = user {
            print("✅ Step 4: Chat Screen received user: \(user.name)")
        } else {
            print("❌ Error: Chat Screen user is NIL!")
        }

        setupSeedMessages()
        setupMessageKit()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupSeedMessages() {
        messages = [
            Message(
                sender: mySender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-300),
                kind: .text("May I know about the plants you have? 🤗")
            ),
            Message(
                sender: otherSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-200),
                kind: .text("Sureee I would love to tell lets meet at 7? 🤗")
            ),
            Message(
                sender: mySender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-100),
                kind: .text("That sounds perfect! See you then.")
            )
        ]
    }

private func setupMessageKit() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageInputBar.delegate = self

        // Input bar styling
        messageInputBar.inputTextView.placeholder = "Message..."
        messageInputBar.inputTextView.font = UIFont.systemFont(ofSize: 15)

        // Send button — only shows when text is present
        messageInputBar.sendButton.setTitle("Send", for: .normal)
        messageInputBar.sendButton.setTitleColor(.brandGreen, for: .normal)
        messageInputBar.sendButton.setTitleColor(.systemGray3, for: .disabled)
        messageInputBar.sendButton.setImage(nil, for: .normal)   // no icon, title only
        
        // Input bar appearance
        messageInputBar.backgroundView.backgroundColor = .clear
        messageInputBar.contentView.backgroundColor = .systemBackground
        messageInputBar.contentView.layer.cornerRadius = 20
        messageInputBar.contentView.layer.masksToBounds = true
        
        // Add some padding so the input bar doesn't touch the very edges if possible
        messageInputBar.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        // Remove the mic/attachment buttons from both sides
        messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
        messageInputBar.leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Reload so the collection view knows about the seed messages
        messagesCollectionView.reloadData()

        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: false)
        }
    }

    private func setupNavigationBar() {
        guard let user = user else { return }

        // Vertical layout: avatar centred above name (like iMessage)
        let avatarSize: CGFloat = 36
        let containerWidth: CGFloat = 180
        let labelHeight: CGFloat = 16
        let spacing: CGFloat = 3
        let totalHeight = avatarSize + spacing + labelHeight
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: totalHeight))

        // Avatar — centred horizontally
        let avatarX = (containerWidth - avatarSize) / 2
        let avatarImageView = UIImageView(frame: CGRect(x: avatarX, y: 0, width: avatarSize, height: avatarSize))
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarSize / 2

        let imageName = UserSession.shared.profileImageString(for: user.id)
        if imageName.isEmpty {
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
            avatarImageView.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
            avatarImageView.contentMode = .scaleAspectFit
        } else {
            avatarImageView.configureImage(with: imageName)
        }

        // Name label — centred below avatar
        let nameLabel = UILabel(frame: CGRect(x: 0, y: avatarSize + spacing, width: containerWidth, height: labelHeight))
        nameLabel.text = user.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
        nameLabel.textAlignment = .center

        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        navigationItem.titleView = containerView

        // Remove any right bar button (e.g. video call)
        navigationItem.rightBarButtonItem = nil
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {

    var currentSender: any SenderType {
        return mySender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> any MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: any MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.brandGreen : UIColor.white
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: any MessageType,
                             at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            avatarView.isHidden = true
        } else {
            avatarView.isHidden = false
            avatarView.backgroundColor = .clear  // removes the grey ring

            let imageName = user.flatMap { UserSession.shared.profileImageString(for: $0.id) } ?? ""
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
            let placeholder = UIImage(systemName: "person.circle.fill", withConfiguration: config)

            if imageName.isEmpty {
                avatarView.set(avatar: Avatar(image: placeholder))
            } else {
                let img = UIImage(named: imageName) ?? placeholder
                avatarView.set(avatar: Avatar(image: img))
            }
        }
    }

    func messageStyle(for message: any MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {

    func avatarSize(for message: any MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return isFromCurrentSender(message: message) ? .zero : CGSize(width: 32, height: 32)
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMessage = Message(
            sender: mySender,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(trimmed)
        )

        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()

        // Use reloadData to avoid section-count mismatch crashes
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}
