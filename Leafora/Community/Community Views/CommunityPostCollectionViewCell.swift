//
//  CommunityPostCollectionViewCell.swift
//  Leafora
//

import UIKit

class CommunityPostCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var topUsernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var captionLabel: UITextView!
    @IBOutlet weak var bottomUsernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var viewAllCommentsButton: UIButton!
    
    @IBOutlet weak var badgeStackView: UIStackView!
    @IBOutlet weak var badgeDateLabel: UILabel!
    @IBOutlet weak var badgeLocationButton: UIButton!

    // MARK: - Identity
    static let identifier = "CommunityPostCollectionViewCell"
    static let nibName    = "CommunityPostCollectionViewCell"

    // MARK: - Callbacks
    // callbacks only; counts come from Post model
    var onLikeTapped:    (() -> Void)?
    var onCommentTapped: (() -> Void)?
    var onSaveTapped:    (() -> Void)?
    var onProfileTapped: (() -> Void)?
    var onMenuTapped:    (() -> Void)?
    var onSeeMoreTapped: (() -> Void)?
    var onLocationTapped: (() -> Void)?

    // MARK: - Local UI State
    private var isExpanded: Bool = false
    private var canExpand:  Bool = false

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupDoubleTapGesture()
    }

    // MARK: - Setup
    private func setupUI() {
        profileImageView.layer.cornerRadius = 17.5
        profileImageView.clipsToBounds      = true
        profileImageView.contentMode        = .scaleAspectFill

        postImageView.contentMode  = .scaleAspectFill
        postImageView.clipsToBounds = true

        let separator = UIView()
        separator.backgroundColor = UIColor.label.withAlphaComponent(0.1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(profileTap)

        let captionTap = UITapGestureRecognizer(target: self, action: #selector(captionLabelTapped))
        captionTap.cancelsTouchesInView = false
        captionLabel.isUserInteractionEnabled = true
        captionLabel.addGestureRecognizer(captionTap)
        
        captionLabel.linkTextAttributes = [
            .foregroundColor: UIColor.brandGreen,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        captionLabel.textContainerInset = .zero
        captionLabel.textContainer.lineFragmentPadding = 0
    }

    private func setupDoubleTapGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired    = 2
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(doubleTap)
    }

    // MARK: - Configure
    func configure(with post: Post, isExpanded: Bool = false) {
        topUsernameLabel.text    = post.author?.username ?? "Unknown"
        bottomUsernameLabel.text = post.author?.username ?? "Unknown"

        captionLabel.text  = post.caption
        self.isExpanded    = isExpanded
        self.canExpand     = post.caption.count > 45

        captionLabel.textContainer.maximumNumberOfLines = isExpanded ? 0 : 1
        captionLabel.textContainer.lineBreakMode = isExpanded ? .byWordWrapping : .byTruncatingTail
        
        seeMoreButton.isHidden     = isExpanded ? true : !canExpand

        // counts come from current post
        likesCountLabel.text = "\(post.likesCount)"
        commentsCountLabel.text = "\(post.commentsCount)"

        // show only when comments exist
        viewAllCommentsButton.isHidden = post.commentsCount == 0

        timestampLabel.text    = post.displayTimestamp
        timestampLabel.isHidden = false

        profileImageView.configureImage(with: post.author?.profileImageString ?? "person.circle.fill")
        postImageView.configureImage(with: post.postImageString)

        // like state from post model
        setLikeButton(liked: post.isLikedByMe)

        // save state from post model
        setSaveButton(saved: post.isSaved)
        
        if post.isPlantationDrive == true {
            contentView.backgroundColor = UIColor(red: 0.90, green: 0.97, blue: 0.90, alpha: 1.0)
            contentView.layer.borderColor = UIColor.brandGreen.cgColor
            contentView.layer.borderWidth = 2.0
            contentView.layer.cornerRadius = 12
            badgeStackView.isHidden = false
            
            if let dateString = post.plantationDate, let date = ISO8601DateFormatter().date(from: dateString) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, h:mm a"
                badgeDateLabel.text = "🌱 \(formatter.string(from: date))"
            } else {
                badgeDateLabel.text = "🌱 TBA"
            }
            badgeLocationButton.setTitle("📍 \(post.locationName ?? "Unknown")", for: .normal)
        } else {
            contentView.backgroundColor = .systemBackground
            contentView.layer.borderWidth = 0
            contentView.layer.cornerRadius = 0
            badgeStackView.isHidden = true
        }
    }

    // MARK: - Button State Helpers
    private func setLikeButton(liked: Bool) {
        let image = UIImage(systemName: liked ? "heart.fill" : "heart")
        likeButton.setImage(image, for: .normal)
        likeButton.tintColor = liked ? .systemRed : .label
    }

    private func setSaveButton(saved: Bool) {
        let image = UIImage(systemName: saved ? "bookmark.fill" : "bookmark")
        saveButton.setImage(image, for: .normal)
    }

    // MARK: - Actions

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        // update icon immediately
        let willLike = likeButton.tintColor != .systemRed
        setLikeButton(liked: willLike)

        // repository handles count update
        onLikeTapped?()
    }

    @IBAction func commentButtonTapped(_ sender: UIButton) {
        onCommentTapped?()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // update icon immediately
        let willSave = saveButton.image(for: .normal) == UIImage(systemName: "bookmark")
        setSaveButton(saved: willSave)
        onSaveTapped?()
    }

    @IBAction func menuButtonTapped(_ sender: UIButton) { onMenuTapped?() }
    @IBAction func seeMoreTapped(_ sender: UIButton)    { onSeeMoreTapped?() }
    @IBAction func viewAllCommentsTapped(_ sender: UIButton) { onCommentTapped?() }
    @IBAction func locationButtonTapped(_ sender: UIButton) { onLocationTapped?() }

    @objc private func profileImageTapped() { onProfileTapped?() }
    @objc private func captionLabelTapped() { if canExpand { onSeeMoreTapped?() } }

    // MARK: - Double Tap
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        // if already liked, just animate
        guard likeButton.tintColor != .systemRed else {
            showHeartAnimation(at: gesture.location(in: postImageView))
            return
        }
        setLikeButton(liked: true)
        // same as like button tap
        onLikeTapped?()
        showHeartAnimation(at: gesture.location(in: postImageView))
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        postImageView.image    = nil
        commentsCountLabel.text = nil
        viewAllCommentsButton.isHidden = true
        setLikeButton(liked: false)
        setSaveButton(saved: false)
        isExpanded = false
        canExpand  = false
    }

    // MARK: - Heart Animation
    private func showHeartAnimation(at point: CGPoint) {
        let size: CGFloat  = 80
        let heartView      = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        heartView.center   = point
        heartView.contentMode = .scaleAspectFit

        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .bold)
        heartView.image     = UIImage(systemName: "heart.fill", withConfiguration: config)
        heartView.tintColor = UIColor(red: 0.30, green: 0.75, blue: 0.40, alpha: 1.0)
        heartView.layer.shadowColor   = UIColor(red: 0.15, green: 0.55, blue: 0.25, alpha: 0.7).cgColor
        heartView.layer.shadowOffset  = CGSize(width: 0, height: 4)
        heartView.layer.shadowRadius  = 8
        heartView.layer.shadowOpacity = 1.0
        heartView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        heartView.alpha     = 0
        postImageView.addSubview(heartView)

        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            heartView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            heartView.alpha     = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
                heartView.transform = .identity
            } completion: { _ in
                UIView.animateKeyframes(withDuration: 0.6, delay: 0.05) {
                    UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.15) {
                        heartView.transform = CGAffineTransform(rotationAngle:  .pi / 12)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.15) {
                        heartView.transform = CGAffineTransform(rotationAngle: -.pi / 10)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.30, relativeDuration: 0.15) {
                        heartView.transform = CGAffineTransform(rotationAngle:  .pi / 14)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.45, relativeDuration: 0.15) {
                        heartView.transform = CGAffineTransform(rotationAngle: -.pi / 16)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.60, relativeDuration: 0.15) {
                        heartView.transform = .identity
                    }
                } completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
                        heartView.alpha     = 0
                        heartView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    } completion: { _ in
                        heartView.removeFromSuperview()
                    }
                }
            }
        }
    }
}
