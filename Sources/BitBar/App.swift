import ServiceManagement
import Async
import AppKit
import SwiftyUserDefaults
import Config
import Parser
import Script

#if DEBUG
  var Defaults = UserDefaults(suiteName: "\(App.id).Debug")!
#endif

/**
  Global values and helpers
*/
class App {
  /**
    Bundle id for current application, i.e com.getbitbar
  */
  static var id: CFString {
    return currentBundle.bundleIdentifier! as CFString
  }

  /**
    Absolut path to the resource path
  */
  static var resourcePath: String {
    return currentBundle.resourcePath!
  }

  /**
    URL to project page
  */
  static var website: URL {
    return URL(string: "https://getbitbar.com/")!
  }

  /**
    Absolute URL to plugins folder
  */
  static var pluginURL: URL? {
    if let path = pluginPath {
      return URL(fileURLWithPath: path, isDirectory: true)
    }

    return nil
  }

  /**
    Absolute path to plugins folder
  */
  static var pluginPath: String? {
    return Defaults[.pluginPath]
  }

  /**
    Does the application start at login?
  */
  static var autostart: Bool {
    return Defaults[.startAtLogin] ?? false
  }

  /**
    Open @url in browser
  */
  static func open(url: URL) {
    NSWorkspace.shared().open(url)
  }

  static func open(url: String) {
    open(url: URL(string: url)!)
  }

  static func open(script: String, args: [String] = []) {
    App.openScript(inTerminal: script, args: args) { maybe in
      if let error = maybe {
        log.error("Could not open \(script) in terminal: \(error)")
      }
    }
  }

  static func open(script: Action.Script) {
    open(script: script.path, args: script.args)
  }

  static func open(script: Script) {
    open(script: script.path, args: script.args)
  }

  /**
    Open @path in Finder
  */
  static func open(path: String) {
    NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: path)
  }

  static func startAtLogin(_ state: Bool) {
    Defaults[.startAtLogin] = state
    SMLoginItemSetEnabled(helperId as CFString, state)
  }

  /**
    Update absolute path to plugin folder
  */
  static func update(pluginPath: String?) {
    if let path = pluginPath {
      Defaults[.pluginPath] = path
    } else {
      Defaults.remove(.pluginPath)
    }
  }

  /**
    Retrieve the absolute path for a resource
    I.e App.path(forResource: "sub.1m.sh")
  */
  static func path(forResource path: String) -> String {
    return NSString.path(withComponents: [resourcePath, path])
  }

  static func isConfigDisabled() -> Bool {
    return Defaults[.disabled] ?? false
  }

  /**
    Is this a test? Used by the Tray class to
    prevent the menu bar from flickering during testing
  */
  static func isInTestMode() -> Bool {
    return ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil
  }

  static func isTravis() -> Bool {
    return ProcessInfo.processInfo.environment["TRAVIS"] != nil
  }

  static func terminateHelperApp() {
    for app in NSWorkspace.shared().runningApplications {
      guard let id = app.bundleIdentifier else { continue }
      if id == helperId {
        DistributedNotificationCenter.default().post(name: .terminate, object: id)
      }
    }
  }

  static var port: Int {
    return config.cliPort
    // let defaultPort = 9120
    // let dict = plist
    //
    // if isInTestMode(), let port = dict["TestPort"] as? Int {
    //   return port
    // }
    //
    // #if DEBUG
    //   if let port = dict["DevPort"] as? Int {
    //     return port
    //   }
    // #else
    //   if let port = dict["ProdPort"] as? Int {
    //     return port
    //   }
    // #endif
    //
    // return defaultPort
  }

  static var version: String {
    if let version = plist["CFBundleVersion"] as? String {
      return version
    }

    return "Unknown"
  }

  static var plist: [String: AnyObject] {
    guard let path = Bundle.main.path(forResource: "BitBar", ofType: "plist") else {
      return [:]
    }

    if let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
      return dict
    }

    return [:]
  }

  static func openScript(inTerminal path: String, args: [String], block: @escaping (String?) -> Void) {
    let escape = { (val: String) in val.replace("\"", "\\\"").replace(" ", "\\ ") }
    let input = ([escape(path)] + args.map(escape)).joined(separator: " ")
    let tell = [
      "tell application \"Terminal\" \n",
      "do script \"\(input)\" \n",
      "activate \n",
      "end tell"
    ].joined()

    Async.background {
      guard let script = NSAppleScript(source: tell) else {
        return "Could not parse script: \(tell)"
      }

      let errors = script.executeAndReturnError(nil)
      guard errors.numberOfItems == 0 else {
        return "Received errors when running script \(errors)"
      }

      return nil
    }.main(block)
  }

  private static let currentBundle = Bundle.main
  private static let helperId = "com.getbitbar.Startup"
  static let config = Config()
}
