import Foundation

struct EnvironmentValues: @unchecked Sendable {
  @TaskLocal static var current = EnvironmentValues()
  private let lock = NSLock()
  private var storage: [String: any Sendable] = [:]
  
  subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
    get {
      lock.lock()
      defer { lock.unlock() }
      let value = storage[key.storageKey] as? K.Value
      return storage[key.storageKey] as? K.Value ?? key.defaultValue
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      storage[key.storageKey] = newValue
    }
  }
}

private extension EnvironmentKey {
  static var storageKey: String { "\(Self.self)" }
}

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
