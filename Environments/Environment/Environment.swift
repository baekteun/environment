import Foundation

@propertyWrapper
struct Environment<T: Sendable> {
  public init(_ keyPath: WritableKeyPath<EnvironmentValues, T>) {
    self.keyPath = keyPath
  }
  
  public var wrappedValue: T {
    get { EnvironmentValues[keyPath] }
//    set { EnvironmentValues[keyPath] = newValue }
  }
  
  private let keyPath: WritableKeyPath<EnvironmentValues, T>
}
