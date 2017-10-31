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
