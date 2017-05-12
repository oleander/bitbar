@testable import BitBar

class MockParent: Parent, Hashable {
  var root: Parent?
  var hashValue: Int {
    return Int(bitPattern: ObjectIdentifier(self))
  }

  static func == (lhs: MockParent, rhs: MockParent) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  func on(_ event: MenuEvent) {
    let menu = menuRefs[self]!
    if eventRefs[menu.id] == nil {
      eventRefs[menu.id] = []
    }
    eventRefs[menu.id]! += [event]
  }
}
