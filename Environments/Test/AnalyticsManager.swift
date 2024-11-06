import Foundation

struct AnalyticsManager: Sendable {
  func test() {
    print("ASDF")
  }
}

struct AnalyticsManagerKey: EnvironmentKey {
  static let defaultValue: AnalyticsManager = AnalyticsManager()
}

extension EnvironmentValues {
  var analyticsManager: AnalyticsManager {
    get { self[AnalyticsManagerKey.self] }
    set { self[AnalyticsManagerKey.self] = newValue }
  }
}
