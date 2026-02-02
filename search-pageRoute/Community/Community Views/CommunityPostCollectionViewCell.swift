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
    
    // MARK: - Properties
    static let identifier = "CommunityPostCollectionViewCell"
    static let nibName = "CommunityPostCollectionViewCell"
    
    // Callbacks for button actions
    var onLikeTapped: ((Bool, Int) -> Void)?
    var onCommentTapped: (() -> Void)?
    var onSaveTapped: (() -> Void)?
    var onProfileTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Profile Image
//        profileImageView.layer.cornerRadius = 20 // Half of 40x40
//        profileImageView.clipsToBounds = true
//        profileImageView.contentMode = .scaleAspectFill
//        
//        // Post Image
//        postImageView.contentMode = .scaleAspectFill
//        postImageView.clipsToBounds = true
//        
//        // Labels
//        usernameLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        likesCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//        captionLabel.font = UIFont.systemFont(ofSize: 14)
//        captionLabel.numberOfLines = 2
//        timestampLabel.font = UIFont.systemFont(ofSize: 12)
//        timestampLabel.textColor = .secondaryLabel
//        
//        // Buttons
//        likeButton.tintColor = .label
//        commentButton.tintColor = .label
//        saveButton.tintColor = .label
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Configuration
    func configure(with post: Post) {
        topUsernameLabel.text = post.author?.username
        
        //BOTTOM Labels -> Username + Caption
        bottomUsernameLabel.text = post.author?.username
        captionLabel.text = post.caption
        timestampLabel.text = post.timestamp
        likesCountLabel.text = "\(post.likesCount)"
        
        // Configure images
        if let author = post.author {
            let imageName = CommunityDataStore.shared.profileImageString(for: author.id)
            profileImageView.configureImage(with: imageName)
        }
        postImageView.configureImage(with: post.postImageString)
        
        // Add this temporarily at the bottom of configure()
        timestampLabel.text = "TEST TIME"
        timestampLabel.isHidden = false
        // MARK: - TIME LOGIC
            // 1. Safely unwrap the string. If it's nil, use empty string.
            let dateString = post.timestamp
            
            // 2. Check if empty immediately
            if dateString.isEmpty {
                timestampLabel.text = "Just now"
            } else {
                // 3. Try ISO8601 Format (Most common)
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                if let date = isoFormatter.date(from: dateString) {
                    timestampLabel.text = date.timeAgoDisplay()
                } else {
                    // 4. Fallback: Try Standard Date Format
                    let simpleFormatter = DateFormatter()
                    // If your backend sends "2025-01-25 14:30:00", change this to "yyyy-MM-dd HH:mm:ss"
                    simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    
                    if let date = simpleFormatter.date(from: dateString) {
                        timestampLabel.text = date.timeAgoDisplay()
                    } else {
                        // 5. FINAL SAFETY NET
                        // If we can't convert it, show the raw string.
                        // This ensures the label NEVER disappears.
                        timestampLabel.text = dateString
                    }
                }
            }
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
        let newCount = Int(likesCountLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0
        let updatedCount = isLiked ? newCount + 1 : newCount - 1
        likesCountLabel.text = "\(updatedCount)"
        
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
