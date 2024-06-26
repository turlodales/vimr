/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 */

import Cocoa
import RxSwift

extension NvimView {
  override public func setFrameSize(_ newSize: NSSize) {
    super.setFrameSize(newSize)

    if self.isInitialResize {
      self.isInitialResize = false
      self.launchNeoVim(self.discreteSize(size: newSize))
      return
    }

    if self.usesLiveResize {
      self.resizeNeoVimUi(to: newSize)
      return
    }

    if self.inLiveResize || self.currentlyResizing { return }

    // There can be cases where the frame is resized not by live resizing,
    // eg when the window is resized by window management tools.
    // Thus, we make sure that the resize call is made when this happens.
    self.resizeNeoVimUi(to: newSize)
  }

  override public func viewDidEndLiveResize() {
    super.viewDidEndLiveResize()
    self.resizeNeoVimUi(to: self.bounds.size)
  }

  func discreteSize(size: CGSize) -> Size {
    Size(
      width: Int(floor(size.width / self.cellSize.width)),
      height: Int(floor(size.height / self.cellSize.height))
    )
  }

  func resizeNeoVimUi(to size: CGSize) {
    self.currentEmoji = self.randomEmoji()

    let discreteSize = self.discreteSize(size: size)
    if discreteSize == self.ugrid.size {
      self.markForRenderWholeView()
      return
    }

    self.offset.x = floor((size.width - self.cellSize.width * discreteSize.width.cgf) / 2)
    self.offset.y = floor((size.height - self.cellSize.height * discreteSize.height.cgf) / 2)

    self.bridge
      .resize(width: discreteSize.width, height: discreteSize.height)
      .subscribe(onError: { [weak self] error in
        self?.log.error("Error in \(#function): \(error)")
      })
      .disposed(by: self.disposeBag)
  }

  private func launchNeoVim(_ size: Size) {
    self.log.info("=== Starting neovim...")
    let sockPath = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("vimr_\(self.uuid).sock").path

    self.log.info("NVIM_LISTEN_ADDRESS=\(sockPath)")

    // We wait here, since the user of NvimView cannot subscribe
    // on the Completable. We could demand that the user call launchNeoVim()
    // by themselves, but...
    try? self.bridge
      .runLocalServerAndNvim(width: size.width, height: size.height)
      .andThen(self.api.run(at: sockPath))
      .andThen(
        self.sourceFileUrls.reduce(Completable.empty()) { prev, url in
          prev
            .andThen(
              self.api.exec(src: "source \(url.shellEscapedPath)", output: true)
                .asCompletable()
            )
        }
      )
      .andThen(self.api.subscribe(event: NvimView.rpcEventName))
      .wait()
  }

  private func randomEmoji() -> String {
    let idx = Int.random(in: 0..<emojis.count)
    guard let scalar = UnicodeScalar(emojis[idx]) else { return "😎" }

    return String(scalar)
  }
}

private let emojis: [UInt32] = [
  0x1F600...0x1F64F,
  0x1F910...0x1F918,
  0x1F980...0x1F984,
  0x1F9C0...0x1F9C0,
].flatMap { $0 }
