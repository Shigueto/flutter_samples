//
//  FlutterStubViewController.swift
//  IOSFullScreen
//
//  Created by Allan Shigueto Akishino on 21/12/23.
//

import Foundation

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import Flutter

class FlutterContainerViewController: UIViewController {

    var methodChannel : FlutterMethodChannel?
    var count = 0
    var flutterEngine : FlutterEngine?
    var flutterViewController : FlutterViewController?
    let allowHeadlessExecution : Bool = true
    let addAsSubview : Bool = true
    var updateCounter : (_ count: Int) -> Void = {_ in }

    func addCounterCallback(updateCounter : @escaping (_ count: Int) -> Void) {
        self.updateCounter = updateCounter
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!addAsSubview) {
            if let viewController = flutterViewController {
                self.present(viewController, animated: true) {
                    print("flutterViewController - FlutterViewController has been presented")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("flutterViewController - viewDidLoad - allowHeadlessExecution=\(allowHeadlessExecution), addAsSubview=\(addAsSubview)")
        // Instantiate Flutter engine
        self.flutterEngine = FlutterEngine(name: "io.flutter", project: nil, allowHeadlessExecution: allowHeadlessExecution)
        self.flutterEngine?.run(withEntrypoint: nil)

        if let flutterEngine = self.flutterEngine {
            methodChannel = FlutterMethodChannel(name: "dev.flutter.example/counter",
                                                 binaryMessenger: flutterEngine.binaryMessenger)
            methodChannel?.setMethodCallHandler({ [weak self]
                (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                if let strongSelf = self {
                    switch(call.method) {
                    case "incrementCounter":
                        strongSelf.count += 1
                        strongSelf.updateCounter(strongSelf.count)
                        strongSelf.reportCounter()
                    case "requestCounter":
                        strongSelf.reportCounter()
                    case "exit":
                        strongSelf.onExit()
                    default:
                        // Unrecognized method name
                        print("Unrecognized method name: \(call.method)")
                    }
                }
            })
            flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
            if (addAsSubview) {
                guard let childController = flutterViewController else { return }
                view.addSubview(childController.view)
                childController.view.frame = view.frame
                childController.didMove(toParent: self)
            }
        }
    }

    func reportCounter() {
        methodChannel?.invokeMethod("reportCounter", arguments: count)
    }

    func onExit() {
        self.dismiss(animated: true)
        if allowHeadlessExecution {
            engineCleanup()
        }
    }

    func engineCleanup() {
        let deregisterNotifications = NSSelectorFromString("deregisterNotifications")
        flutterEngine?.viewController?.perform(deregisterNotifications)
        flutterEngine?.destroyContext()
        let dealloc = NSSelectorFromString("dealloc")
        flutterEngine?.viewController?.perform(dealloc)
        flutterEngine = nil
        flutterViewController = nil
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("flutterViewController - viewDidDisappear")

    }
}
