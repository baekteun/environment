import Foundation

@dynamicMemberLookup
final class LockedState<Value>: @unchecked Sendable {
  private var _value: Value
  private let lock = NSLock()

  init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
    self._value = try value()
  }

  subscript<Subject: Sendable>(dynamicMember keyPath: KeyPath<Value, Subject>) -> Subject {
    self.lock.sync {
      self._value[keyPath: keyPath]
    }
  }

  @discardableResult
  func withValue<T: Sendable>(
    _ operation: @Sendable (inout Value) throws -> T
  ) rethrows -> T {
    try self.lock.sync {
      var value = self._value
      defer {
        self._value = value
      }
      return try operation(&value)
    }
  }

  func setValue(_ newValue: @autoclosure @Sendable () throws -> Value) rethrows {
    try self.lock.sync {
      self._value = try newValue()
    }
  }
}

extension LockedState where Value: Sendable {
  var value: Value {
    self.lock.sync {
      self._value
    }
  }
}

extension NSLock {
  @inlinable
  @discardableResult
  func sync<R>(work: () throws -> R) rethrows -> R {
    self.lock()
    defer { self.unlock() }
    return try work()
  }
}
