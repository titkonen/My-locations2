import Foundation

extension String {
  mutating func add(text: String?, separetedBy separator: String = "") {
    if let text = text {
      if !isEmpty {
        self += separator
      }
      self += text
    }
  }
}
