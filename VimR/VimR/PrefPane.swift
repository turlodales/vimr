/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 */

import Cocoa

class PrefPane: NSView {
  // Return true to place this to the upper left corner when the scroll view is bigger than this view.
  override var isFlipped: Bool {
    true
  }

  var displayName: String {
    preconditionFailure("Please override")
  }

  var pinToContainer: Bool {
    false
  }

  func paneWillAppear() {
    // noop, override
  }

  func windowWillClose() {
    // noop, override
  }
}

// MARK: - Control Utils

extension PrefPane {
  func paneTitleTextField(title: String) -> NSTextField {
    let field = NSTextField.defaultTitleTextField()
    field.font = NSFont.boldSystemFont(ofSize: 16)
    field.alignment = .left
    field.stringValue = title
    return field
  }

  func titleTextField(title: String) -> NSTextField {
    let field = NSTextField.defaultTitleTextField()
    field.alignment = .right
    field.stringValue = title
    return field
  }

  func infoTextField(markdown: String) -> NSTextField {
    let field = NSTextField(forAutoLayout: ())
    field.backgroundColor = NSColor.clear
    field.isEditable = false
    field.isBordered = false
    field.usesSingleLineMode = false

    // both are needed, otherwise hyperlink won't accept mousedown
    field.isSelectable = true
    field.allowsEditingTextAttributes = true

    field.attributedStringValue = NSAttributedString.infoLabel(markdown: markdown)

    return field
  }

  func configureCheckbox(button: NSButton, title: String, action: Selector) {
    button.title = title
    button.setButtonType(.switch)
    button.target = self
    button.action = action
  }
}
