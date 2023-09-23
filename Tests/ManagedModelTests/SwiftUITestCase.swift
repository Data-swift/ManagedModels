//
//  Created by Helge Heß.
//  Copyright © 2023 ZeeZide GmbH.
//

import XCTest
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

class SwiftUITestCase: XCTestCase {
  #if os(macOS)
  private lazy var window : NSWindow? = {
    let window = NSWindow(
      contentRect: .init(x: 0, y: 0, width: 720, height: 480),
      styleMask: .utilityWindow, backing: .buffered, defer: false
    )
    return window
  }()
  
  func constructView<V: View>(_ view: V,
                              waitingFor expectation: XCTestExpectation) throws
  {
    let window = try XCTUnwrap(self.window)
    window.contentViewController = NSHostingController(rootView: view)
    window.contentViewController?.view.layout()
    wait(for: [expectation], timeout: 2)
  }
  #elseif canImport(UIKit)
  private lazy var window : UIWindow? = {
    let window = UIWindow(frame: .init(x: 0, y: 0, width: 720, height: 480))
    window.isHidden = false
    return window
  }()
  
  func constructView<V: View>(_ view: V,
                              waitingFor expectation: XCTestExpectation) throws
  {
    let window = try XCTUnwrap(self.window)
    window.rootViewController = UIHostingController(rootView: view)
    window.rootViewController?.view.layoutIfNeeded()
    wait(for: [expectation], timeout: 2)
  }
  #endif
}
