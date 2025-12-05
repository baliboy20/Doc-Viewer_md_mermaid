import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Get the main window and Flutter view controller
    let mainWindow = NSApplication.shared.windows.first
    if let flutterViewController = mainWindow?.contentViewController as? FlutterViewController {
      // Create method channel for menu communication
      methodChannel = FlutterMethodChannel(
        name: "com.florence.docs/menu",
        binaryMessenger: flutterViewController.engine.binaryMessenger
      )
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @IBAction func showHelp(_ sender: Any) {
    // Send message to Flutter to show help documentation
    methodChannel?.invokeMethod("showHelp", arguments: nil)
  }
}
