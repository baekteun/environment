import Foundation

protocol SubscriptionManager: Sendable {
  func subscribe()
}

struct SubscriptionManagerImpl: SubscriptionManager {
  func subscribe() {
    print("FDZZ")
  }
}

struct SubscriptionManagerTest: SubscriptionManager {
  let countState = LockedState(0)

  func subscribe() {
    let newCount = countState.withValue { count in
      defer { count += 1 }

      return count
    }
    print(newCount)
  }
}

struct SubscriptionManagerKey: EnvironmentKey {
  static let defaultValue: any SubscriptionManager = SubscriptionManagerImpl()
}

extension EnvironmentValues {
  var subscriptionManager: any SubscriptionManager {
    get { self[SubscriptionManagerKey.self] }
    set { self[SubscriptionManagerKey.self] = newValue }
  }
}
