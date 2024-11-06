import Foundation

struct EnvironmentValues: Sendable {
  @TaskLocal static var current = EnvironmentValues()
  fileprivate let storage = LockedState([String: any Sendable]())

  init() {
    DispatchQueue.main.async {
      guard
        let XCTestObservation = objc_getProtocol("XCTestObservation"),
        let XCTestObservationCenter = NSClassFromString("XCTestObservationCenter"),
        let XCTestObservationCenter = XCTestObservationCenter as Any as? NSObjectProtocol,
        let XCTestObservationCenterShared =
          XCTestObservationCenter
          .perform(Selector(("sharedTestObservationCenter")))?
          .takeUnretainedValue()
      else { return }
      let testCaseWillStartBlock: @convention(block) (AnyObject) -> Void = { _ in
        print("FDSA")
        EnvironmentValues.$current.withValue(EnvironmentValues.current) {
          EnvironmentValues.current.storage.setValue([:])
        }
      }
      let testCaseWillStartImp = imp_implementationWithBlock(testCaseWillStartBlock)
      class_addMethod(
        TestObserver.self, Selector(("testCaseWillStart:")), testCaseWillStartImp, nil)
      class_addProtocol(TestObserver.self, XCTestObservation)
      _ =
        XCTestObservationCenterShared
        .perform(Selector(("addTestObserver:")), with: TestObserver())
    }
  }

  subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
    get {
      storage.withValue {
        $0[key.storageKey] as? K.Value ?? key.defaultValue
      }
    }
    set {
      storage.withValue { $0[key.storageKey] = newValue }
    }
  }

  static subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
    get {
      current.storage.withValue {
        $0[key.storageKey] as? K.Value ?? key.defaultValue
      }
    }
    set {
      current.storage.withValue { $0[key.storageKey] = newValue }
    }
  }

  static subscript<T: Sendable>(_ keyPath: WritableKeyPath<EnvironmentValues, T>) -> T {
    get {
      current[keyPath: keyPath]
    }
    set {
      var currentEnvironmentValues = current
      currentEnvironmentValues[keyPath: keyPath] = newValue
      $current.withValue(currentEnvironmentValues) {
        currentEnvironmentValues
      }
    }
  }
}

extension WritableKeyPath: @unchecked Sendable {}

private extension EnvironmentKey {
  static var storageKey: String { "\(Self.self)" }
}

private final class TestObserver {}

func withDependencies<R>(
  _ updateValuesOperation: (inout EnvironmentValues) throws -> Void,
  operation: () throws -> R
) rethrows -> R {
  var dependencies = EnvironmentValues.current
  try updateValuesOperation(&dependencies)
  return try EnvironmentValues.$current.withValue(dependencies) {
    try operation()
  }
}
