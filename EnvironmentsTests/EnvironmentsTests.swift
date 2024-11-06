//
//  EnvironmentsTests.swift
//  EnvironmentsTests
//
//  Created by 최형우 on 11/5/24.
//

import Testing
@testable import Environments

struct EnvironmentsTests {
  @Test
  func test_basic_environment_access() {
    // Given
    let testClass = TestClass()
    
    // When
    testClass.logMessage("Hello")
    
    // Then
    let logs = testClass.logger.getLogs()
    #expect(logs == ["Hello"])
  }

  @Test
  func test_environment_update() {
    // Given
    let newLogger = Logger()

    let testClass = withDependencies {
      $0.logger = newLogger
    } operation: {
      TestClass()
    }
    
    // When
    testClass.logMessage("New message")
    
    // Then
    let logs = testClass.logger.getLogs()
    #expect(logs == ["New message"])
  }

  @Test
  func test_mutable_locked_state() {
    // Given
    let testClass = withDependencies {
      $0.subscriptionManager = SubscriptionManagerTest()
    } operation: {
      TestClass()
    }

    
    // When
    
    testClass.subscribe()
    testClass.subscribe()
    
    // Then
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
    static let defaultValue = Logger()
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
      print(logger.getLogs())
        logger.log(message)
    }
    
    func subscribe() {
        subscriptionManager.subscribe()
    }
}
