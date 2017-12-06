//
//  KinAccounts.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

public final class KinAccounts {
    private var cache = [Int: KinAccount]()
    private let cacheLock = NSLock()

    private weak var accountStore: KinAccountStore?

    public var count: Int {
        return accountStore?.accounts.size() ?? 0
    }

    public subscript(_ index: Int) -> KinAccount? {
        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        return account(at: index)
    }

    func createAccount(with passphrase: String) throws -> KinAccount {
        guard let accountStore = accountStore else {
            throw KinError.internalInconsistency
        }

        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        let account = try KinEthereumAccount(gethAccount: accountStore.createAccount(passphrase: passphrase),
                                             accountStore: accountStore)

        cache[count - 1] = account

        return account
    }

    func deleteAccount(at index: Int, with passphrase: String) throws {
        guard let accountStore = accountStore else {
            throw KinError.internalInconsistency
        }

        self.cacheLock.lock()
        defer {
            self.cacheLock.unlock()
        }

        guard let account = account(at: index) as? KinEthereumAccount else {
            throw KinError.internalInconsistency
        }

        try accountStore.delete(account: account.gethAccount, passphrase: passphrase)
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
                    let accountStore = self.accountStore,
                    let account = try? accountStore.accounts.get(index) {
                    let kinAccount = KinEthereumAccount(gethAccount: account, accountStore: accountStore)

                    cache[index] = kinAccount

                    return kinAccount
                }

                return nil
            }()
    }

    init(accountStore: KinAccountStore) {
        self.accountStore = accountStore
    }

    func flushCache() {
        for account in cache.values {
            (account as? KinEthereumAccount)?.deleted = true
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

