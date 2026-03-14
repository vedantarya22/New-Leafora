import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - Sender
struct Sender: SenderType {
    var senderId:    String
    var displayName: String
}

// MARK: - Message
struct Message: MessageType {
    var sender:    SenderType
    var messageId: String
    var sentDate:  Date
    var kind:      MessageKind
}

// MARK: - ChatViewController
class ChatViewController: MessagesViewController {

    // MARK: - Properties
    var user: User?

    // ✅ Computed so it reads the latest cached user at access time
    var mySender: Sender {
        Sender(
            senderId:    UserSession.shared.currentLoggedInUserID,
            displayName: UserSession.shared.currentUser?.name ?? "Me"
        )
    }

    var otherSender: Sender {
        Sender(
            senderId:    user?.id ?? "other",
            displayName: user?.name ?? "User"
        )
    }

    var messages: [Message] = []
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        messagesCollectionView.backgroundColor = .clear

        setupSeedMessages()
        setupMessageKit()
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Seed Messages
    private func setupSeedMessages() {
        messages = [
            Message(
                sender:    mySender,
                messageId: UUID().uuidString,
                sentDate:  Date().addingTimeInterval(-300),
                kind:      .text("May I know about the plants you have? 🤗")
            ),
            Message(
                sender:    otherSender,
                messageId: UUID().uuidString,
                sentDate:  Date().addingTimeInterval(-200),
                kind:      .text("Sureee I would love to tell lets meet at 7? 🤗")
            ),
            Message(
                sender:    mySender,
                messageId: UUID().uuidString,
                sentDate:  Date().addingTimeInterval(-100),
                kind:      .text("That sounds perfect! See you then.")
            )
        ]
    }

    // MARK: - MessageKit Setup
    private func setupMessageKit() {
        messagesCollectionView.messagesDataSource      = self
        messagesCollectionView.messagesLayoutDelegate  = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate                       = self

        messageInputBar.inputTextView.placeholder = "Message..."
        messageInputBar.inputTextView.font        = UIFont.systemFont(ofSize: 15)

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

        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: false)
        }
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        guard let user = user else { return }

        let avatarSize: CGFloat     = 36
        let containerWidth: CGFloat = 180
        let labelHeight: CGFloat    = 16
        let spacing: CGFloat        = 3
        let totalHeight             = avatarSize + spacing + labelHeight

        let containerView = UIView(frame: CGRect(
            x: 0, y: 0, width: containerWidth, height: totalHeight
        ))

        let avatarX = (containerWidth - avatarSize) / 2
        let avatarImageView = UIImageView(frame: CGRect(
            x: avatarX, y: 0, width: avatarSize, height: avatarSize
        ))
        avatarImageView.contentMode        = .scaleAspectFill
        avatarImageView.clipsToBounds      = true
        avatarImageView.layer.cornerRadius = avatarSize / 2

        // ✅ User.profileImageString is String (non-optional) — safe to call .isEmpty directly
        if ((user.profileImageString?.isEmpty) != nil) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
            avatarImageView.image       = UIImage(systemName: "person.circle.fill",
                                                  withConfiguration: config)
            avatarImageView.contentMode = .scaleAspectFit
        } else {
            avatarImageView.configureImage(with: user.profileImageString)
        }

        let nameLabel = UILabel(frame: CGRect(
            x: 0, y: avatarSize + spacing, width: containerWidth, height: labelHeight
        ))
        nameLabel.text          = user.name
        nameLabel.font          = UIFont.boldSystemFont(ofSize: 13)
        nameLabel.textAlignment = .center

        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        navigationItem.titleView          = containerView
        navigationItem.rightBarButtonItem = nil
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

    func backgroundColor(for message: any MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .brandGreen : .white
    }

    func textColor(for message: any MessageType,
                   at indexPath: IndexPath,
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

            // ✅ User.profileImageString is String — use directly, no ?? needed
            let imageString = user?.profileImageString ?? ""
            if imageString.isEmpty {
                avatarView.set(avatar: Avatar(image: placeholder))
            } else {
                let img = UIImage(named: imageString) ?? placeholder
                avatarView.set(avatar: Avatar(image: img))
            }
        }
    }

    func messageStyle(for message: any MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message)
            ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {

    func avatarSize(for message: any MessageType,
                    at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        isFromCurrentSender(message: message) ? .zero : CGSize(width: 32, height: 32)
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(Message(
            sender:    mySender,
            messageId: UUID().uuidString,
            sentDate:  Date(),
            kind:      .text(trimmed)
        ))

        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}
