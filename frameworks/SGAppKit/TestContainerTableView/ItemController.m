#import "ItemController.h"

@implementation ItemController
- (id) initWithIndex : (int) anIndex
{
	if(self = [self init]){
		NSString	*str;
		
		str = [[self titleField] stringValue];
		str = [str stringByAppendingFormat : @"(%d)", anIndex];
		
		[[self titleField] setStringValue : str];
	}
	return self;
}
- (id) init
{
	if(self = [super init]){
		[NSBundle loadNibNamed : @"Item"
						 owner : self];
	}
	return self;
}
/* Accessor for m_itemView */
- (SGContainerView *) itemView
{
	return m_itemView;
}
/* Accessor for m_titleField */
- (NSTextField *) titleField
{
	return m_titleField;
}
@end
