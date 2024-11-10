//
//  EnvironmentsTests.swift
//  EnvironmentsTests
//
//  Created by 최형우 on 11/5/24.
//

import Foundation
import Testing

@testable import Environments

struct EnvironmentValuesTests {
  @Test
  func test_test_class_integration() {
    let logger = Logger()
    let subscriptionManager = SubscriptionManagerTest()

    let testClass = withDependencies {
      $0.logger = logger
      $0.subscriptionManager = subscriptionManager
    } operation: {
      TestClass()
    }

    testClass.logMessage("Test message")
    testClass.subscribe()

    #expect(logger.getLogs() == ["Test message"])
    #expect(subscriptionManager.countState.value == 1)
  }

  @Test
  func test_concurrent_access() async throws {
    let logger = Logger()
    let testClass = withDependencies {
      $0.logger = logger
    } operation: {
      TestClass()
    }

    async let task1 = {
      testClass.logMessage("Message 1")
    }()

    async let task2 = {
      testClass.logMessage("Message 2")
    }()

    _ = try await (task1, task2)

    let logs = logger.getLogs()
    #expect(logs.count == 2)
    #expect(logs.contains("Message 1"))
    #expect(logs.contains("Message 2"))
  }
}

struct Logger: Sendable, Equatable {
  static func == (lhs: Logger, rhs: Logger) -> Bool {
    lhs.id == rhs.id
  }

  private let id = UUID()
  private let storage = LockedState([String]())

  func log(_ message: String) {
    storage.withValue { $0.append(message) }
  }

  func getLogs() -> [String] {
    storage.withValue { $0 }
  }
}

struct LoggerKey: EnvironmentKey {
  static let defaultValue: Logger = Logger()
}

extension EnvironmentValues {
  var logger: Logger {
    get { self[LoggerKey.self] }
    set { self[LoggerKey.self] = newValue }
  }
}

final class TestClass {
  @Environment(\.logger) var logger
  @Environment(\.subscriptionManager) var subscriptionManager

  func logMessage(_ message: String) {
    logger.log(message)
  }

  func subscribe() {
    subscriptionManager.subscribe()
  }
}
