import Foundation

protocol EnvironmentKey: Sendable {
  associatedtype Value: Sendable

  static var defaultValue: Self.Value { get }
}
