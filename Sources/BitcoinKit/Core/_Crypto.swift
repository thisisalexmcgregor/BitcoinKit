//
//  BitcoinKit.Private.swift
//  BitcoinKit
//
//  Created by Yusuke Ito on 03/24/18.
//  Copyright © 2018 Yusuke Ito. All rights reserved.
//

import Foundation
import CryptoSwift
import secp256k1

public class _Crypto {
    public static func signMessage(_ data: Data, withPrivateKey privateKey: Data) throws -> Data {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        let status = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            privateKey.withUnsafeBytes {
                secp256k1_ecdsa_sign(
                    ctx,
                    signature,
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    nil,
                    nil
                )
            }
        }
        guard status == 1 else { throw CryptoError.signFailed }
        
        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)
        
        var length: size_t = 128
        var der = Data(count: length)
        guard der.withUnsafeMutableBytes({
            return secp256k1_ecdsa_signature_serialize_der(
                ctx,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                &length,
                normalizedsig
            ) }) == 1 else { throw CryptoError.noEnoughSpace }
        der.count = length
        
        return der
    }
    
    public static func verifySignature(_ signature: Data, message: Data, publicKey: Data) throws -> Bool {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signaturePointer = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signaturePointer.deallocate() }
        guard signature.withUnsafeBytes({
            secp256k1_ecdsa_signature_parse_der(
                ctx,
                signaturePointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                signature.count
            )
        }) == 1 else {
            throw CryptoError.signatureParseFailed
        }
        
        let pubkeyPointer = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkeyPointer.deallocate() }
        guard publicKey.withUnsafeBytes({
            secp256k1_ec_pubkey_parse(
                ctx,
                pubkeyPointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                publicKey.count
            ) }) == 1 else {
            throw CryptoError.publicKeyParseFailed
        }
        
        guard message.withUnsafeBytes ({
            secp256k1_ecdsa_verify(
                ctx,
                signaturePointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                pubkeyPointer) }) == 1 else {
            return false
        }
        
        return true
    }
    
    public enum CryptoError: Error {
        case signFailed
        case noEnoughSpace
        case signatureParseFailed
        case publicKeyParseFailed
    }
}
