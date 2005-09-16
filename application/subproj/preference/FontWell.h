/* FontWell */

#import <Cocoa/Cocoa.h>

@interface FontWell : NSButton
{
}

- (void)activate;
- (void)deactivate;

@end

@interface NSObject(FontWellDelegate)
// You should use item's tag to specify which Fontwell is the target.
- (NSFont *) getFontOf : (int) tagNum;
- (void) changeFontOf : (int) tagNum To: (NSFont *) newFont;
@end
