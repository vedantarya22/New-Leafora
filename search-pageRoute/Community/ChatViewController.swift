//
//  ChatViewController.swift
//  Leafora
//

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

    var user: User!

    private var messages:     [Message] = []
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    private var mySender: Sender {
        Sender(senderId:    UserSession.shared.currentLoggedInUserID,
               displayName: UserSession.shared.currentUser?.name ?? "Me")
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
        subscribeToIncomingMessages()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ChatSocketManager.shared.onMessageReceived = nil
    }

    // MARK: - Load History
    private func loadMessages() {
        let stored = ChatManager.shared.fetchMessages(with: user.id)
        messages = stored.map { entity in
            let isMe = entity.senderId == UserSession.shared.currentLoggedInUserID
            return Message(
                sender:    isMe ? mySender : otherSender,
                messageId: entity.id ?? UUID().uuidString,
                sentDate:  entity.timestamp ?? Date(),
                kind:      .text(entity.text ?? "")
            )
        }
        messagesCollectionView.reloadData()
        scrollToBottom(animated: false)
    }

    // MARK: - Incoming Socket Messages
    private func subscribeToIncomingMessages() {
        ChatSocketManager.shared.onMessageReceived = { [weak self] socketMsg in
            guard let self = self, socketMsg.senderId == self.user.id else { return }
            let msg = Message(
                sender:    self.otherSender,
                messageId: socketMsg.messageId,
                sentDate:  socketMsg.timestamp,
                kind:      .text(socketMsg.text)
            )
            self.messages.append(msg)
            self.messagesCollectionView.reloadData()
            self.scrollToBottom(animated: true)
            NotificationCenter.default.post(name: .didSendMessage, object: nil,
                                            userInfo: ["userId": socketMsg.senderId])
        }
    }

    // MARK: - MessageKit Setup
    private func setupMessageKit() {
        
        messagesCollectionView.messagesDataSource      = self
        messagesCollectionView.messagesLayoutDelegate  = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate                       = self
        messagesCollectionView.allowsSelection            = false
          messagesCollectionView.allowsMultipleSelection    = false

        let inputTV = messageInputBar.inputTextView
        inputTV.placeholder          = "Type a message..."
        inputTV.placeholderTextColor = UIColor.systemGray3
        inputTV.font                 = .systemFont(ofSize: 15, weight: .regular)
        inputTV.textContainerInset   = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        inputTV.layer.cornerRadius   = 20
        inputTV.layer.borderWidth    = 1
        inputTV.layer.borderColor    = UIColor.systemGray5.cgColor
        inputTV.backgroundColor      = .white

        let sendButton = messageInputBar.sendButton
        sendButton.setTitle(nil, for: .normal)
        let sendConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill",
                                    withConfiguration: sendConfig), for: .normal)
        sendButton.tintColor = .brandGreen
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

        messageInputBar.backgroundView.backgroundColor = UIColor(red: 0.96, green: 0.98,
                                                                  blue: 0.96, alpha: 1.0)
        messageInputBar.separatorLine.backgroundColor  = UIColor.brandGreen.withAlphaComponent(0.15)
        messageInputBar.separatorLine.height           = 1.0
        messageInputBar.padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 8)
        messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
        messageInputBar.leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        messageInputBar.contentView.backgroundColor     = .clear
        messageInputBar.contentView.layer.cornerRadius  = 0
        messageInputBar.contentView.layer.masksToBounds = false
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        let avatarSize: CGFloat     = 36
        let containerWidth: CGFloat = 180
        let labelHeight: CGFloat    = 16
        let spacing: CGFloat        = 3
        let totalHeight             = avatarSize + spacing + labelHeight

        let container  = UIView(frame: CGRect(x: 0, y: 0,
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

    private func shouldShowDateHeader(at indexPath: IndexPath) -> Bool {
        guard indexPath.section > 0 else { return true }
        let current  = messages[indexPath.section].sentDate
        let previous = messages[indexPath.section - 1].sentDate
        return !Calendar.current.isDate(current, inSameDayAs: previous)
    }

    private func dateHeaderString(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date)     { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        let f = DateFormatter(); f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    private func timeString(for date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    // MARK: - Find Message Bubble View
    // Recursively walks subviews to find MessageContainerView
    private func findMessageBubble(in view: UIView) -> UIView? {
        if String(describing: type(of: view)) == "MessageContainerView" { return view }
        for sub in view.subviews {
            if let found = findMessageBubble(in: sub) { return found }
        }
        return nil
    }

    // MARK: - Build Targeted Preview (bubble only, no cell background)
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration,
                                      in collectionView: UICollectionView) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell      = collectionView.cellForItem(at: indexPath)
        else { return nil }

        let bubbleView = findMessageBubble(in: cell) ?? cell.contentView

        //  Force restore the bubble color before preview renders
        let isMe = indexPath.section < messages.count &&
                   messages[indexPath.section].sender.senderId == UserSession.shared.currentLoggedInUserID
        bubbleView.backgroundColor = isMe
            ? .brandGreen
            : UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)

        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        params.shadowPath      = UIBezierPath()
        params.visiblePath     = UIBezierPath(roundedRect: bubbleView.bounds, cornerRadius: 18)

        return UITargetedPreview(view: bubbleView, parameters: params)
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

    func cellTopLabelAttributedText(for message: any MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {
        guard shouldShowDateHeader(at: indexPath) else { return nil }
        return NSAttributedString(
            string: dateHeaderString(for: message.sentDate),
            attributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
    }

    func messageBottomLabelAttributedText(for message: any MessageType,
                                          at indexPath: IndexPath) -> NSAttributedString? {
        NSAttributedString(
            string: timeString(for: message.sentDate),
            attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.tertiaryLabel
            ]
        )
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: any MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message)
            ? .brandGreen
            : UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
    }

    func textColor(for message: any MessageType, at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message)
            ? .white
            : UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
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
            avatarView.set(avatar: Avatar(
                image: imgString.isEmpty ? placeholder : UIImage(named: imgString) ?? placeholder
            ))
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

    func headerViewSize(for section: Int,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize { .zero }

    func footerViewSize(for section: Int,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        CGSize(width: 0, height: 4)
    }

    func cellTopLabelHeight(for message: any MessageType, at indexPath: IndexPath,
                            in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        shouldShowDateHeader(at: indexPath) ? 32 : 0
    }

    func messageBottomLabelHeight(for message: any MessageType, at indexPath: IndexPath,
                                  in messagesCollectionView: MessagesCollectionView) -> CGFloat { 16 }

    func messageBottomLabelAlignment(for message: any MessageType, at indexPath: IndexPath,
                                     in messagesCollectionView: MessagesCollectionView)
    -> LabelAlignment? {
        isFromCurrentSender(message: message)
            ? LabelAlignment(textAlignment: .right,
                             textInsets: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 16))
            : LabelAlignment(textAlignment: .left,
                             textInsets: UIEdgeInsets(top: 2, left: 48, bottom: 0, right: 0))
    }

    func cellTopLabelAlignment(for message: any MessageType, at indexPath: IndexPath,
                               in messagesCollectionView: MessagesCollectionView)
    -> LabelAlignment? {
        LabelAlignment(textAlignment: .center, textInsets: .zero)
    }
}

// MARK: - UICollectionViewDelegate (Context Menu)
extension ChatViewController  {

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard indexPath.section < messages.count else { return nil }
        let message = messages[indexPath.section]

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: nil,   // ✅ nil = use targetedPreview below instead of custom preview
            actionProvider: { [weak self] _ in
                guard let self = self else { return nil }
                var actions: [UIAction] = []

                if case .text(let text) = message.kind {
                    actions.append(UIAction(
                        title: "Copy",
                        image: UIImage(systemName: "doc.on.doc")
                    ) { _ in
                        UIPasteboard.general.string = text
                    })
                }

                actions.append(UIAction(
                    title: "Delete for Me",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    guard let self = self else { return }
                    let section = indexPath.section
                    guard section < self.messages.count else { return }
                    ChatManager.shared.deleteMessage(byId: message.messageId)
                    self.messages.remove(at: section)
                    self.messagesCollectionView.performBatchUpdates({
                        self.messagesCollectionView.deleteSections(IndexSet(integer: section))
                    }, completion: nil)
                })

                return UIMenu(title: "", children: actions)
            }
        )
    }

    // ✅ These two methods tell iOS to highlight/animate ONLY the bubble, not the full cell
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration
                        configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration, in: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration
                        configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration, in: collectionView)
    }
    
    
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    // Add these two methods inside the extension ChatViewController { block
    // (the same extension with your context menu methods)

   
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        ChatManager.shared.sendMessage(to: user.id, text: trimmed)

        messages.append(Message(
            sender:    mySender,
            messageId: UUID().uuidString,
            sentDate:  Date(),
            kind:      .text(trimmed)
        ))

        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
        messagesCollectionView.reloadData()
        scrollToBottom(animated: true)

        NotificationCenter.default.post(name: .didSendMessage, object: nil,
                                        userInfo: ["userId": user.id])
    }
    
    
    
}
