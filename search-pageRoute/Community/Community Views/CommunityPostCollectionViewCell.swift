//
//  CommunityPostCollectionViewCell.swift
//  PlantApp
//
//  Created by SDC-USER on 24/01/26.
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
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var bottomUsernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    // MARK: - Properties
    static let identifier = "CommunityPostCollectionViewCell"
    static let nibName = "CommunityPostCollectionViewCell"
    
    // Callbacks for button actions
    var onLikeTapped: ((Bool, Int) -> Void)?
    var onCommentTapped: (() -> Void)?
    var onSaveTapped: (() -> Void)?
    var onProfileTapped: (() -> Void)?
    var onMenuTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupDoubleTapGesture()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Profile Image
        profileImageView.layer.cornerRadius = 17.5 // Half of 35x35
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // Separator line at the bottom of each post
        let separator = UIView()
        separator.backgroundColor = UIColor.label.withAlphaComponent(0.12)
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupDoubleTapGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(doubleTap)
    }
    
    // MARK: - Double Tap Heart Animation
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        // Only like (not unlike) on double-tap, just like Instagram
        if !likeButton.isSelected {
            likeButton.isSelected = true
            
            // Update heart button
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemRed
            
            // Update count
            let newCountText = likesCountLabel.text?.components(separatedBy: " ").first ?? "0"
            let newCount = Int(newCountText.replacingOccurrences(of: ",", with: "")) ?? 0
            let updatedCount = newCount + 1
            likesCountLabel.text = "\(updatedCount) likes"
            
            // Notify parent
            onLikeTapped?(true, updatedCount)
        }
        
        // Always show the heart animation (even if already liked)
        showHeartAnimation(at: gesture.location(in: postImageView))
    }
    
    private func showHeartAnimation(at point: CGPoint) {
        // Create the green 3D heart
        let heartSize: CGFloat = 80
        let heartImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: heartSize, height: heartSize))
        heartImageView.center = point
        heartImageView.contentMode = .scaleAspectFit
        
        // Use SF Symbol heart.fill with a leafy green color
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .bold)
        heartImageView.image = UIImage(systemName: "heart.fill", withConfiguration: config)
        heartImageView.tintColor = UIColor(red: 0.30, green: 0.75, blue: 0.40, alpha: 1.0) // Fresh leaf green
        
        // Add a subtle 3D shadow for depth
        heartImageView.layer.shadowColor = UIColor(red: 0.15, green: 0.55, blue: 0.25, alpha: 0.7).cgColor
        heartImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        heartImageView.layer.shadowRadius = 8
        heartImageView.layer.shadowOpacity = 1.0
        
        // Start small and transparent
        heartImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        heartImageView.alpha = 0
        
        postImageView.addSubview(heartImageView)
        
        // Animate: pop in with spring -> settle -> wobble -> fade out
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            heartImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            heartImageView.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
                heartImageView.transform = .identity
            } completion: { _ in
                // Wobble animation using keyframes
                UIView.animateKeyframes(withDuration: 0.6, delay: 0.05, options: []) {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.15) {
                        heartImageView.transform = CGAffineTransform(rotationAngle: .pi / 12) // tilt right
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.15) {
                        heartImageView.transform = CGAffineTransform(rotationAngle: -.pi / 10) // tilt left
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.30, relativeDuration: 0.15) {
                        heartImageView.transform = CGAffineTransform(rotationAngle: .pi / 14) // tilt right smaller
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.45, relativeDuration: 0.15) {
                        heartImageView.transform = CGAffineTransform(rotationAngle: -.pi / 16) // tilt left smaller
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.60, relativeDuration: 0.15) {
                        heartImageView.transform = .identity // settle
                    }
                } completion: { _ in
                    // Fade out
                    UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
                        heartImageView.alpha = 0
                        heartImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    } completion: { _ in
                        heartImageView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    // MARK: - Configuration
    func configure(with post: Post) {
        topUsernameLabel.text = post.author?.username
        
        //BOTTOM Labels -> Username + Caption
        bottomUsernameLabel.text = post.author?.username
        captionLabel.text = post.caption
        timestampLabel.text = post.timestamp
        likesCountLabel.text = "\(post.likesCount) likes"
        
        // Configure images
        if let author = post.author {
            let imageName = UserSession.shared.profileImageString(for: author.id)
            profileImageView.configureImage(with: imageName)
        }
        postImageView.configureImage(with: post.postImageString)
        
        // MARK: - TIME LOGIC
        timestampLabel.text = post.displayTimestamp ?? "Just now"
        timestampLabel.isHidden = false

        // Configure like button
        let likeImage = post.isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        likeButton.setImage(likeImage, for: .normal)
        likeButton.tintColor = post.isLiked ? .systemRed : .label
        
        //Configure save button
        let saveImage = post.isSaved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        saveButton.setImage(saveImage, for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        // Toggle like state
        sender.isSelected.toggle()
        let isLiked = sender.isSelected
        
        // Update UI
        let imageName = isLiked ? "heart.fill" : "heart"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
        sender.tintColor = isLiked ? .systemRed : .label
        
        // Update count
        let newCountText = likesCountLabel.text?.components(separatedBy: " ").first ?? "0"
        let newCount = Int(newCountText.replacingOccurrences(of: ",", with: "")) ?? 0
        let updatedCount = isLiked ? newCount + 1 : newCount - 1
        likesCountLabel.text = "\(updatedCount) likes"
        
        // Notify parent
        onLikeTapped?(isLiked, updatedCount)
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        onCommentTapped?()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        let isSaved = sender.isSelected
        
        let imageName = isSaved ? "bookmark.fill" : "bookmark"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
        
        onSaveTapped?()
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        onMenuTapped?()
    }
    
    @objc private func profileImageTapped() {
        onProfileTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        postImageView.image = nil
        likeButton.isSelected = false
        saveButton.isSelected = false
    }
}
