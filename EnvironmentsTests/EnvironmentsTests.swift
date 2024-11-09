//
//  EnvironmentsTests.swift
//  EnvironmentsTests
//
//  Created by 최형우 on 11/5/24.
//

import Testing
import os
@testable import Environments

struct EnvironmentsTests {
  @Test
  func test_basic_environment_access() async {
    let log = Logger()
    let testClass = withDependencies {
      $0.logger = log
    } operation: {
      TestClass()
    }

    testClass.logMessage("Hello")
    let logs = testClass.logger.getLogs()
    #expect(logs == ["Hello"])
  }

  @Test
  func test_environment_update() async {
    @Environment(\.logger) var logger
    logger.log("HELLO")
    #expect(logger.getLogs() == ["HELLO"])

    let newLogger = Logger()

    let testClass = withDependencies {
      $0.logger = newLogger
    } operation: {
      TestClass()
    }

    testClass.logMessage("New message")
    
    let logs = testClass.logger.getLogs()
    #expect(logs == ["New message"])
  }

  @Test
  func test_mutable_locked_state() async {
    let testClass = withDependencies {
      $0.subscriptionManager = SubscriptionManagerTest()
    } operation: {
      TestClass()
    }
    
    testClass.subscribe()
    testClass.subscribe()

    #expect(testClass.subscriptionManager is SubscriptionManagerTest)
    #expect((testClass.subscriptionManager as? SubscriptionManagerTest)?.countState.value == 2)
  }
}

struct Logger: Sendable {
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
