//
//  Post.swift
//  Leafora
//

import Foundation

// MARK: - PostAuthor
struct PostAuthor: Codable {
    let id: String
    let name: String
    let username: String
    // null in backend when user hasn't set a profile image yet
    let profileImageString: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, profileImageString
    }
}

// MARK: - Comment
struct Comment: Codable, Identifiable {
    let id: String
    let postId: String
    let author: PostAuthor?
    let text: String
    let createdAt: String

    var displayTimestamp: String {
        PostRepository.shared.timeAgo(from: createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case postId, text, createdAt
        case author = "userId"
    }
}

// MARK: - Post
struct Post: Codable {
    let id: String
    let author: PostAuthor?
    let postImageString: String
    let caption: String
    let createdAt: String
    var likesCount: Int
    var commentsCount: Int
    var isLikedByMe: Bool
    var isSaved: Bool

    var userId: String { author?.id ?? "" }
    var isLiked: Bool  { isLikedByMe }

    var displayTimestamp: String {
        PostRepository.shared.timeAgo(from: createdAt)
    }

    init(from decoder: Decoder) throws {
        let c           = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(String.self,            forKey: .id)
        author          = try c.decodeIfPresent(PostAuthor.self, forKey: .author)
        postImageString = try c.decode(String.self,            forKey: .postImageString)
        caption         = try c.decode(String.self,            forKey: .caption)
        createdAt       = try c.decode(String.self,            forKey: .createdAt)
        likesCount      = try c.decodeIfPresent(Int.self,      forKey: .likesCount)    ?? 0
        commentsCount   = try c.decodeIfPresent(Int.self,      forKey: .commentsCount) ?? 0
        isLikedByMe     = try c.decodeIfPresent(Bool.self,     forKey: .isLikedByMe)  ?? false
        isSaved         = try c.decodeIfPresent(Bool.self,     forKey: .isSaved)       ?? false
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case author = "userId"
        case postImageString, caption, createdAt
        case likesCount, commentsCount, isLikedByMe, isSaved
    }
}

// MARK: - Feed & Comments Responses
struct FeedResponse: Decodable {
    let posts: [Post]
    let page: Int
    let hasMore: Bool
}

struct CommentsResponse: Decodable {
    let comments: [Comment]
    let page: Int
    let hasMore: Bool
}
