import Foundation

@propertyWrapper
struct Environment<T: Sendable> {
  private let keyPath: WritableKeyPath<EnvironmentValues, T>
  private let initialValues: EnvironmentValues

  public init(_ keyPath: WritableKeyPath<EnvironmentValues, T>) {
    self.keyPath = keyPath
    self.initialValues = EnvironmentValues.current
  }
  
  public var wrappedValue: T {
    get {
      let value = EnvironmentValues.$current.withValue(initialValues) {
        EnvironmentValues.current[keyPath: self.keyPath]
      }
      return value
    }
//    set { EnvironmentValues[keyPath] = newValue }
  }
  
  
}
