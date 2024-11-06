//
//  ViewController.swift
//  Environments
//
//  Created by 최형우 on 11/5/24.
//

import UIKit

class ViewController: UIViewController {
  @Environment(\.analyticsManager) var analyticsManager
  @Environment(\.subscriptionManager) var subscriptionManager

  override func viewDidLoad() {
    super.viewDidLoad()
    analyticsManager.test()

    subscriptionManager.subscribe()
    subscriptionManager.subscribe()

    Task { @MainActor in
      try await Task.sleep(nanoseconds: 1_000_000_000)
      subscriptionManager.subscribe()
    }
  }


}

