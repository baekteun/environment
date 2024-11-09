import Foundation

struct EnvironmentValues: @unchecked Sendable {
  @TaskLocal static var current = EnvironmentValues()
  let storage = LockedState([String: any Sendable]())
  
  subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
    get {
      return storage.withValue { storage in
        if let value = storage[key.storageKey] as? K.Value {
          return value
        } else {
          storage[key.storageKey] = key.defaultValue
          return key.defaultValue
        }
      }
    }
    set {
      storage.withValue {
        $0[key.storageKey] = newValue
      }
    }
  }
}

private extension EnvironmentKey {
  static var storageKey: String { "\(Self.self)" }
}

@discardableResult
func withDependencies<R>(
  _ updateValuesOperation: (inout EnvironmentValues) throws -> Void,
  operation: () throws -> R
) rethrows -> R {
  var dependencies = EnvironmentValues()
  try updateValuesOperation(&dependencies)
  return try EnvironmentValues.$current.withValue(dependencies) {
    return try operation()
  }
}

@discardableResult
func withDependencies<R>(
  isolation: isolated (any Actor)? = #isolation,
  _ updateValuesForOperation: (inout EnvironmentValues) async throws -> Void,
  operation: () async throws -> R
) async rethrows -> R {
  var dependencies = EnvironmentValues()
  try await updateValuesForOperation(&dependencies)
  return try await EnvironmentValues.$current.withValue(dependencies) {
    return try await operation()
  }
}
