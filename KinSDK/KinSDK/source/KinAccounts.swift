//
//  KinAccounts.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import StellarKinKit

public final class KinAccounts {
    private var cache = [Int: KinAccount]()
    private let cacheLock = NSLock()

    private weak var stellar: Stellar?

    public var count: Int {
        return KeyStore.count()
    }

    public subscript(_ index: Int) -> KinAccount? {
        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        return account(at: index)
    }

    func createAccount(with passphrase: String) throws -> KinAccount {
        guard let stellar = stellar else {
            throw KinError.internalInconsistency
        }

        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        let account = try KinStellarAccount(stellarAccount: KeyStore.newAccount(passphrase: passphrase),
                                            stellar: stellar)

        cache[count - 1] = account

        return account
    }

    func deleteAccount(at index: Int, with passphrase: String) throws {
        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        guard let account = account(at: index) as? KinStellarAccount else {
            throw KinError.internalInconsistency
        }

        guard KeyStore.remove(at: index) else {
            throw KinError.unknown
        }

        account.deleted = true

        shiftCache(for: index)
    }

    private func shiftCache(for index: Int) {
        let indexesToShuffle = cache.keys.map { $0 }.filter({ $0 > index }).sorted()

        cache[index] = nil

        var tempCache = [Int: KinAccount]()
        for i in indexesToShuffle {
            tempCache[i - 1] = cache[i]

            cache[i] = nil
        }

        for (index, account) in tempCache {
            cache[index] = account
        }
    }

    private func account(at index: Int) -> KinAccount? {
        return cache[index] ??
            {
                if index < self.count,
                    let stellar = stellar,
                    let stellarAccount = KeyStore.account(at: index) {
                    let kinAccount = KinStellarAccount(stellarAccount: stellarAccount,
                                                       stellar: stellar)

                    cache[index] = kinAccount

                    return kinAccount
                }

                return nil
            }()
    }

    init(stellar: Stellar) {
        self.stellar = stellar
    }

    func flushCache() {
        for account in cache.values {
            (account as? KinStellarAccount)?.deleted = true
        }

        cache.removeAll()
    }
}

extension KinAccounts: Sequence {
    public func makeIterator() -> AnyIterator<KinAccount> {
        var index = 0

        return AnyIterator {
            let account = index <= self.count ? self[index] : nil

            index += 1

            return account
        }
    }
}

