#  Kin iOS SDK

#### A library responsible for creating a new Kin account and managing balance and transactions in Kin.

## Installation

In the meantime, we don't support yet CocoaPods or Carthage. The recommended setup is adding the KinSDK project as a subproject, and having the SDK as a target dependencies. Here is a step by step that we recommend:

1. Clone this repo (as a submodule or in a different directory, it's up to you);
2. Drag `KinSDK.xcodeproj` as a subproject;
3. In your main `.xcodeproj` file, select the desired target(s);
4. Go to **Build Phases**, expand Target Dependencies, and add `KinSDK`;
5. In Swift, `import KinSDK` and you are good to go! (We haven't tested yet Obj-C)

This is how we did the Sample App - you might look at the setup for a concrete example.

## API Usage
### `KinClient`
`KinClient` is where you start from. In order to initialize it, a `ServiceProvider` must be passed. We recommend using `InfuraTestProvider` (please go to [https://infura.io](https://infura.io) and generate an API token) for the test environment:

```swift
let kinClient = try? KinClient(provider: InfuraTestProvider(apiKey: "YourApiToken"))
```

No activity can take place until an account is created. To do so, call `createAccountIfNeeded(with passphrase: String)`. To check if an account already exists, you can inspect the `account` property. The passphrase used to encrypt the account is the same one used to get the key store and send transactions.

### `KinAccount`

#### Public Address and KeyStore
- `var publicAddress: String`: returns the hex string of the account's public address.
- `func keyStore(with passphrase: String) -> throws String`: returns the account's keystore file as JSON. Throws an error in case the passphrase is wrong .**Currently not implemnted yet - method name not final**

#### *Note:*
For the methods below, a sync and an async version are both available. The sync versions will block the current thread until a value is returned (so you should call them from the main thread). The async versions will call the completion block once finished, but **it is the developer's responsibility to dispatch to desired queue.**

#### Checking Balance

- `func balance() throws -> Balance`: returns the current balance of the account.
- `func pendingBalance() throws -> Balance`: returns the pending balance of the account that is waiting for confirmation. **Currently returns a hardcoded value of 20**

#### Sending transactions
- `func sendTransaction(to: String, amount: Double, passphrase: String) throws -> TransactionId`: Sends a specific amount to an account's address, given the passphrase. Throws an error in case the passphrase is wrong. Returns the transaction ID. **Currently returns a hardcoded value of `MockTransactionId`**
