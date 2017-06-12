import Cocoa
import SwiftyBeaver
import AppKit
import Files

class PathSelector: NSObject, NSOpenSavePanelDelegate, GUI {
  private let log = SwiftyBeaver.self
  internal let queue = PathSelector.newQueue(label: "PathSelector")
  private static let title = "Use as Plugins Directory"
  private let panel = NSOpenPanel()
  /**
    @url First folder being displayed in the file selector
  */
  convenience init(withURL url: URL? = nil) {
    self.init()

    if let aURL = url {
      panel.directoryURL = aURL
    }

    panel.prompt = PathSelector.title
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
  }

  func ask(block: @escaping Block<URL>) {
    perform {
      if self.panel.runModal() == NSFileHandlingPanelOKButton {
        if self.panel.urls.count == 1 {
          block(self.panel.urls[0])
        } else {
          self.log.error("Invalid number of urls \(self.panel.urls)")
        }
      } else {
        self.log.info("User pressed close in plugin folder dialog")
      }
    }
  }
}
