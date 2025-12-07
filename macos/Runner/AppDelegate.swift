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

    // Add Git menu items
    setupGitMenu()
  }

  private func setupGitMenu() {
    // Get the main menu
    guard let mainMenu = NSApplication.shared.mainMenu else { return }

    // Create Git menu
    let gitMenu = NSMenu(title: "Git")
    let gitMenuItem = NSMenuItem(title: "Git", action: nil, keyEquivalent: "")
    gitMenuItem.submenu = gitMenu

    // Clone Repository
    let cloneItem = NSMenuItem(
      title: "Clone Repository...",
      action: #selector(cloneRepository(_:)),
      keyEquivalent: "g"
    )
    cloneItem.keyEquivalentModifierMask = [.command, .shift]
    cloneItem.target = self
    gitMenu.addItem(cloneItem)

    gitMenu.addItem(NSMenuItem.separator())

    // Toggle Git Panel
    let togglePanelItem = NSMenuItem(
      title: "Toggle Git Panel",
      action: #selector(toggleGitPanel(_:)),
      keyEquivalent: "g"
    )
    togglePanelItem.keyEquivalentModifierMask = [.command, .control]
    togglePanelItem.target = self
    gitMenu.addItem(togglePanelItem)

    gitMenu.addItem(NSMenuItem.separator())

    // Pull
    let pullItem = NSMenuItem(
      title: "Pull",
      action: #selector(gitPull(_:)),
      keyEquivalent: "p"
    )
    pullItem.keyEquivalentModifierMask = [.command, .shift]
    pullItem.target = self
    gitMenu.addItem(pullItem)

    // Push
    let pushItem = NSMenuItem(
      title: "Push",
      action: #selector(gitPush(_:)),
      keyEquivalent: "P"
    )
    pushItem.keyEquivalentModifierMask = [.command, .shift]
    pushItem.target = self
    gitMenu.addItem(pushItem)

    gitMenu.addItem(NSMenuItem.separator())

    // Commit
    let commitItem = NSMenuItem(
      title: "Commit Changes...",
      action: #selector(gitCommit(_:)),
      keyEquivalent: "k"
    )
    commitItem.keyEquivalentModifierMask = [.command]
    commitItem.target = self
    gitMenu.addItem(commitItem)

    // Refresh Status
    let refreshItem = NSMenuItem(
      title: "Refresh Status",
      action: #selector(refreshGitStatus(_:)),
      keyEquivalent: "r"
    )
    refreshItem.keyEquivalentModifierMask = [.command, .shift]
    refreshItem.target = self
    gitMenu.addItem(refreshItem)

    // Insert Git menu before Window menu
    let windowMenuIndex = mainMenu.indexOfItem(withTitle: "Window")
    if windowMenuIndex >= 0 {
      mainMenu.insertItem(gitMenuItem, at: windowMenuIndex)
    } else {
      mainMenu.addItem(gitMenuItem)
    }
  }

  @IBAction func cloneRepository(_ sender: Any) {
    methodChannel?.invokeMethod("cloneRepository", arguments: nil)
  }

  @IBAction func toggleGitPanel(_ sender: Any) {
    methodChannel?.invokeMethod("toggleGitPanel", arguments: nil)
  }

  @IBAction func gitPull(_ sender: Any) {
    methodChannel?.invokeMethod("gitPull", arguments: nil)
  }

  @IBAction func gitPush(_ sender: Any) {
    methodChannel?.invokeMethod("gitPush", arguments: nil)
  }

  @IBAction func gitCommit(_ sender: Any) {
    methodChannel?.invokeMethod("gitCommit", arguments: nil)
  }

  @IBAction func refreshGitStatus(_ sender: Any) {
    methodChannel?.invokeMethod("refreshGitStatus", arguments: nil)
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
