/* ItemController */

#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>

@interface ItemController : NSObject
{
    IBOutlet SGContainerView *m_itemView;
    IBOutlet NSTextField	 *m_titleField;
}
- (id) initWithIndex : (int) anIndex;
/* Accessor for m_itemView */
- (SGContainerView *) itemView;
/* Accessor for m_titleField */
- (NSTextField *) titleField;
@end
