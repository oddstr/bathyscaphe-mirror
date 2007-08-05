//:CMRToolbarDelegateImp_p.h
#import "CMRToolbarDelegateImp.h"

#import "CocoMonar_Prefix.h"
#import <SGAppKit/SGAppKit.h>



@interface CMRToolbarDelegateImp(Private)
- (NSToolbarItem *) itemForItemIdentifier : (NSString *) anIdentifier
								itemClass : (Class	   ) aClass;
- (NSToolbarItem *) appendToolbarItemWithItemIdentifier : (NSString *) itemIdentifier
                                      localizedLabelKey : (NSString *) label
                               localizedPaletteLabelKey : (NSString *) paletteLabel
                                    localizedToolTipKey : (NSString *) toolTip
                                                 action : (SEL       ) action
                                                 target : (id        ) target;
- (NSToolbarItem *) appendToolbarItemWithClass : (Class		) aClass
								itemIdentifier : (NSString *) itemIdentifier
							 localizedLabelKey : (NSString *) label
					  localizedPaletteLabelKey : (NSString *) paletteLabel
						   localizedToolTipKey : (NSString *) toolTip
										action : (SEL       ) action
										target : (id        ) target;
- (NSMutableDictionary *) itemDictionary;

-(NSArray *) unsupportedItemsArray;
@end



@interface CMRToolbarDelegateImp(Protected)
- (void) initializeToolbarItems : (NSWindow *) aWindow;
- (void) configureToolbar : (NSToolbar *) aToolbar;
@end
