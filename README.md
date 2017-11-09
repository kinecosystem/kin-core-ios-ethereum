#  kinios
### iOS Kin sdk
A library responsible for creating a new Kin account and managing balance and transactions in Kin.

initial interface proposal

#### KinClient
```swift

enum KinError: Error {
    case unknown
    case invalidPassphrase
}

public class KinClient {
    private(set) var account: KinAccount?

    init(with nodeProviderUrl: URL)

    func createAccountIfNecessary(with passphrase: String) throws -> KinAccount
}

typealias Balance = Double
typealias TransactionId = String

typealias TransactionCallback = (TransactionId?, KinError?) -> ()
typealias BalanceCallback = (Balance?, KinError?) -> ()

public class KinAccount {
    private(set) var publicAddress: String

    func privateKey(with passphrase: String) throws -> String?

    func sendTransaction(to: String, amount: Double, passphrase: String, callback: TransactionCallback)

    func sendTransaction(to: String, amount: Double, passphrase: String) throw -> TransactionId

    func balance(callback: BalanceCallback)

    func balance() throws -> Balance

    func pendingBalance(callback: BalanceCallback)

    func pendingBalance() throws -> Balance
}
```

# Test

We use [ethereumjs/testrpc](testrpc) and [Truffle framework](truffle) unit tests.
You should install these first before running the tests:

```bash
# install truffle and testrpc globally
$ npm install -g truffle@3.4.6 ethereumjs-testrpc@4.1.3
# install truffle dependencies locally
$ npm install
```

```bash
# execute your tests in this file
# it exports useful environment variables
# like token contract address and account keys
$ cat ./scripts/run-tests.sh

#!/usr/bin/env bash

# use this script to run your tests

# export account address environment variables
# see this file for available variables
source ./scripts/testrpc-accounts.sh

# export token contract address environment variable
export TOKEN_CONTRACT_ADDRESS=$(cat ./token-contract-address)


# TEST COMMANDS GO HERE
```

```bash
# run your tests
# see Makefile and scripts/ for additional information
$ make test
```

[testrpc]: https://github.com/ethereumjs/testrpc
[truffle]: http://truffleframework.com/
