// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import Flutter

class ViewController: UIViewController {

    @IBOutlet weak var counterLabel: UILabel!

    var methodChannel : FlutterMethodChannel?
    var count = 0
    let originalSample : Bool = false
    let allowHeadlessExecution = true

    var flutterEngine : FlutterEngine?
    //var flutterViewController : FlutterViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewController - originalSample=\(originalSample), allowHeadlessExecution=\(allowHeadlessExecution)")
        if (originalSample) {
            flutterEngine = createEngine()
        }
    }

    func reportCounter() {
        methodChannel?.invokeMethod("reportCounter", arguments: count)
    }

    @IBAction func buttonWasTapped(_ sender: Any) {
        if (originalSample) {
            let flutterEngine: FlutterEngine = self.flutterEngine ?? createEngine()
            let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
            self.present(flutterViewController, animated: true, completion: nil)
        } else {
            let viewController = FlutterContainerViewController()
            viewController.addCounterCallback { count in
                self.counterLabel.text = "Current counter: \(count)"
            }
            self.present(viewController, animated: true, completion: nil)
        }
    }

    func onExit() {
        if allowHeadlessExecution {
            engineCleanup()
        }
    }

    func engineCleanup() {
        let deregisterNotifications = NSSelectorFromString("deregisterNotifications")
        let dealloc = NSSelectorFromString("dealloc")
        flutterEngine?.viewController?.perform(deregisterNotifications)
        flutterEngine?.viewController?.perform(dealloc)
        flutterEngine?.destroyContext()
        flutterEngine = nil
    }

    func createEngine() -> FlutterEngine {
        // Instantiate Flutter engine
        let flutterEngine = FlutterEngine(name: "io.flutter", project: nil, allowHeadlessExecution: allowHeadlessExecution)
        flutterEngine.run(withEntrypoint: nil)
        methodChannel = FlutterMethodChannel(name: "dev.flutter.example/counter",
                                                 binaryMessenger: flutterEngine.binaryMessenger)
        methodChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if let strongSelf = self {
                switch(call.method) {
                case "incrementCounter":
                    strongSelf.count += 1
                    strongSelf.counterLabel.text = "Current counter: \(strongSelf.count)"
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
        return flutterEngine
    }
}
