import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - Sender
struct Sender: SenderType {
    var senderId:    String
    var displayName: String
}

// MARK: - Message  (wraps CoreData entity for MessageKit display)
struct Message: MessageType {
    var sender:    SenderType
    var messageId: String
    var sentDate:  Date
    var kind:      MessageKind
}

// MARK: - ChatViewController
class ChatViewController: MessagesViewController {

    // MARK: - Properties
    // Must be set before pushing this VC
    var user: User!

    private var messages: [Message] = []
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    private var mySender: Sender {
        Sender(
            senderId:    UserSession.shared.currentLoggedInUserID,
            displayName: UserSession.shared.currentUser?.name ?? "Me"
        )
    }

    private var otherSender: Sender {
        Sender(senderId: user.id, displayName: user.name)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        messagesCollectionView.backgroundColor = .clear

        setupMessageKit()
        setupNavigationBar()
        loadMessages()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Load Messages from CoreData
    private func loadMessages() {
        let stored = ChatManager.shared.fetchMessages(with: user.id)

        messages = stored.map { entity in
            let isMe   = entity.senderId == UserSession.shared.currentLoggedInUserID
            let sender = isMe ? mySender : otherSender
            return Message(
                sender:    sender,
                messageId: entity.id ?? UUID().uuidString,
                sentDate:  entity.timestamp ?? Date(),
                kind:      .text(entity.text ?? "")
            )
        }

        messagesCollectionView.reloadData()
        scrollToBottom(animated: false)
    }

    // MARK: - MessageKit Setup
    private func setupMessageKit() {
        messagesCollectionView.messagesDataSource      = self
        messagesCollectionView.messagesLayoutDelegate  = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate                       = self

        messageInputBar.inputTextView.placeholder = "Message..."
        messageInputBar.inputTextView.font        = .systemFont(ofSize: 15)
        messageInputBar.sendButton.setTitle("Send", for: .normal)
        messageInputBar.sendButton.setTitleColor(.brandGreen,  for: .normal)
        messageInputBar.sendButton.setTitleColor(.systemGray3, for: .disabled)
        messageInputBar.sendButton.setImage(nil, for: .normal)

        messageInputBar.backgroundView.backgroundColor  = .clear
        messageInputBar.contentView.backgroundColor     = .systemBackground
        messageInputBar.contentView.layer.cornerRadius  = 20
        messageInputBar.contentView.layer.masksToBounds = true
        messageInputBar.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
        messageInputBar.leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Navigation Bar  (avatar + name centred)
    private func setupNavigationBar() {
        let avatarSize: CGFloat     = 36
        let containerWidth: CGFloat = 180
        let labelHeight: CGFloat    = 16
        let spacing: CGFloat        = 3
        let totalHeight             = avatarSize + spacing + labelHeight

        let container = UIView(frame: CGRect(x: 0, y: 0,
                                             width: containerWidth, height: totalHeight))

        let avatarX    = (containerWidth - avatarSize) / 2
        let avatarView = UIImageView(frame: CGRect(x: avatarX, y: 0,
                                                   width: avatarSize, height: avatarSize))
        avatarView.contentMode        = .scaleAspectFill
        avatarView.clipsToBounds      = true
        avatarView.layer.cornerRadius = avatarSize / 2

        if let img = user.profileImageString, !img.isEmpty {
            avatarView.configureImage(with: img)
        } else {
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
            avatarView.image       = UIImage(systemName: "person.circle.fill",
                                             withConfiguration: config)
            avatarView.contentMode = .scaleAspectFit
        }

        let nameLabel = UILabel(frame: CGRect(x: 0, y: avatarSize + spacing,
                                              width: containerWidth, height: labelHeight))
        nameLabel.text          = user.name
        nameLabel.font          = .boldSystemFont(ofSize: 13)
        nameLabel.textAlignment = .center

        container.addSubview(avatarView)
        container.addSubview(nameLabel)
        navigationItem.titleView          = container
        navigationItem.rightBarButtonItem = nil
    }

    // MARK: - Helpers
    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: animated)
        }
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {

    var currentSender: any SenderType { mySender }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> any MessageType {
        messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: any MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .brandGreen : .white
    }

    func textColor(for message: any MessageType, at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }

    func configureAvatarView(_ avatarView: AvatarView,
                             for message: any MessageType,
                             at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            avatarView.isHidden = true
        } else {
            avatarView.isHidden        = false
            avatarView.backgroundColor = .clear
            let config      = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
            let placeholder = UIImage(systemName: "person.circle.fill", withConfiguration: config)
            let imgString   = user.profileImageString ?? ""
            if imgString.isEmpty {
                avatarView.set(avatar: Avatar(image: placeholder))
            } else {
                avatarView.set(avatar: Avatar(image: UIImage(named: imgString) ?? placeholder))
            }
        }
    }

    func messageStyle(for message: any MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message)
            ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {

    func avatarSize(for message: any MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        isFromCurrentSender(message: message) ? .zero : CGSize(width: 32, height: 32)
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 1. Persist to CoreData
        ChatManager.shared.sendMessage(to: user.id, text: trimmed)

        // 2. Append to local array for instant display
        messages.append(Message(
            sender:    mySender,
            messageId: UUID().uuidString,
            sentDate:  Date(),
            kind:      .text(trimmed)
        ))

        // 3. Update UI
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
        messagesCollectionView.reloadData()
        scrollToBottom(animated: true)

        // 4. Tell PeopleViewController to refresh its preview row
        NotificationCenter.default.post(name: .didSendMessage, object: nil,
                                        userInfo: ["userId": user.id])
    }
}
