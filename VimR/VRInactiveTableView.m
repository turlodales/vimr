/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import "VRInactiveTableView.h"


/**
* Copied and slightly modified from TextMate
*/
@implementation VRInactiveTableView

- (NSCell *)preparedCellAtColumn:(NSInteger)column row:(NSInteger)row {
  NSCell *cell = [super preparedCellAtColumn:column row:row];
  if (cell.isHighlighted && self.window.isKeyWindow) {
    cell.backgroundStyle = NSBackgroundStyleDark;
    cell.highlighted = NO;
  }

  return cell;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
  if (!self.window.isKeyWindow) {
    return [super highlightSelectionInClipRect:clipRect];
  }

  NSRange range = [self rowsInRect:clipRect];
  [[NSColor alternateSelectedControlColor] set];
  [self.selectedRowIndexes enumerateRangesInRange:range options:0 usingBlock:^(NSRange range, BOOL *stop) {
    for (NSUInteger row = range.location; row < NSMaxRange(range); ++row) {
      NSRect rect = [self rectOfRow:row];
      rect.size.height -= 1;
      NSRectFill(rect);
    }
  }];
}

@end
