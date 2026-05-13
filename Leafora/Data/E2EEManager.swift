//  E2EEManager.swift
//  Leafora
//
//  Handles all E2EE crypto using Apple's CryptoKit.
//  Algorithm: X25519 (Curve25519) ECDH key agreement → HKDF → AES-256-GCM
//
//  Key insight: ECDH is symmetric.
//  sharedSecret = ECDH(myPrivKey, otherPubKey)
//                = ECDH(otherPrivKey, myPubKey)   ← same result on both devices
//  So the same derivation decrypts both sent AND received messages in a room.

import Foundation
import CryptoKit

enum E2EEError: Error {
    case invalidPublicKey
    case invalidCiphertext
    case encodingFailed
    case encryptionFailed
    case decryptionFailed
}

final class E2EEManager {
    static let shared = E2EEManager()
    private init() {}

    // Salt is fixed and public — its purpose is domain separation, not secrecy.
    private let hkdfSalt = Data("leafora-chat-v1".utf8)

    // MARK: - Key Pair

    /// Returns the existing private key from Keychain, or generates + stores a new one.
    func getOrCreatePrivateKey(for userId: String) -> Curve25519.KeyAgreement.PrivateKey {
        if let data = KeychainManager.shared.getPrivateKey(for: userId),
           let key  = try? Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data) {
            return key
        }
        let newKey = Curve25519.KeyAgreement.PrivateKey()
        KeychainManager.shared.savePrivateKey(newKey.rawRepresentation, for: userId)
        print("E2EE: generated new key pair for \(userId)")
        return newKey
    }

    /// Base64-encoded public key — safe to upload to the server.
    func publicKeyBase64(for userId: String) -> String {
        getOrCreatePrivateKey(for: userId).publicKey.rawRepresentation.base64EncodedString()
    }

    // MARK: - Encrypt

    /// Encrypts plaintext for a recipient.
    /// Returns base64(12-byte IV | ciphertext | 16-byte GCM auth tag).
    func encrypt(_ plaintext: String, recipientPublicKeyBase64: String) throws -> String {
        let myId     = UserSession.shared.currentLoggedInUserID
        let myPrivKey = getOrCreatePrivateKey(for: myId)
        let symKey   = try deriveKey(myPrivKey: myPrivKey, otherPubKeyBase64: recipientPublicKeyBase64)

        guard let plaintextData = plaintext.data(using: .utf8) else { throw E2EEError.encodingFailed }
        let sealed = try AES.GCM.seal(plaintextData, using: symKey)
        guard let combined = sealed.combined else { throw E2EEError.encryptionFailed }
        return combined.base64EncodedString()
    }

    // MARK: - Decrypt

    /// Decrypts a ciphertext using the other participant's public key.
    /// Pass the OTHER user's public key regardless of message direction — ECDH is symmetric.
    func decrypt(_ ciphertextBase64: String, otherUserPublicKeyBase64: String) throws -> String {
        guard let cipherData = Data(base64Encoded: ciphertextBase64) else {
            throw E2EEError.invalidCiphertext
        }
        let myId      = UserSession.shared.currentLoggedInUserID
        let myPrivKey = getOrCreatePrivateKey(for: myId)
        let symKey    = try deriveKey(myPrivKey: myPrivKey, otherPubKeyBase64: otherUserPublicKeyBase64)

        let sealedBox = try AES.GCM.SealedBox(combined: cipherData)
        let plainData = try AES.GCM.open(sealedBox, using: symKey)
        guard let text = String(data: plainData, encoding: .utf8) else {
            throw E2EEError.decryptionFailed
        }
        return text
    }

    // MARK: - Private

    private func deriveKey(myPrivKey: Curve25519.KeyAgreement.PrivateKey,
                           otherPubKeyBase64: String) throws -> SymmetricKey {
        guard let keyData = Data(base64Encoded: otherPubKeyBase64) else {
            throw E2EEError.invalidPublicKey
        }
        let otherPubKey  = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: keyData)
        let sharedSecret = try myPrivKey.sharedSecretFromKeyAgreement(with: otherPubKey)
        return sharedSecret.hkdfDerivedSymmetricKey(
            using:          SHA256.self,
            salt:           hkdfSalt,
            sharedInfo:     Data(),
            outputByteCount: 32
        )
    }
}
