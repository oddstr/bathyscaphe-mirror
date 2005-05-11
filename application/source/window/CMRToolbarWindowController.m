//:CMRToolbarWindowController.m
#import "CMRToolbarWindowController_p.h"


@implementation CMRToolbarWindowController
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
- (void) dealloc
{
	[m_toolbarDelegateImp release];
	[super dealloc];
}
//////////////////////////////////////////////////////////////////////
/////////////////////// [ クラスメソッド ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
+ (Class) toolbarDelegateImpClass
{
	return Nil;
}
//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
// Keybinding support
- (void) selectNextKeyView : (id) sender
{
	[[self window] selectNextKeyView : sender];
}
- (void) selectPreviousKeyView : (id) sender
{
	[[self window] selectPreviousKeyView : sender];
}


- (id<CMRToolbarDelegate>) toolbarDelegate
{
	if(nil == m_toolbarDelegateImp){
		Class		class_;
		
		class_ = [[self class] toolbarDelegateImpClass];
		UTILAssertConformsTo(
				class_,
				@protocol(CMRToolbarDelegate));
		m_toolbarDelegateImp = [[class_ alloc] init];
	}
	return m_toolbarDelegateImp;
}

// Window Management
- (void) windowDidLoad
{
	[super windowDidLoad];
	[[self window] setAutodisplay : NO];
	[[self window] setViewsNeedDisplay : NO];
	[self setupUIComponents];
	[[self window] setAutodisplay : YES];
	[[self window] setViewsNeedDisplay : YES];
}
@end



@implementation CMRToolbarWindowController(ViewSetup)
- (void) setupUIComponents
{
	[[self toolbarDelegate] attachToolbarWithWindow : [self window]];
}
@end



@implementation CMRToolbarWindowController(NSToolbarItemValidation)
- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	NSString		*identifier_;
	NSToolbarItem	*item_;
	
	identifier_ = [theItem itemIdentifier];
	item_ = [[self toolbarDelegate]
				itemForItemIdentifier : identifier_];
	
	// 自分の持っているツールバー項目しかチェックしない。
	// 実際のチェックはサブクラスに任せる。
	return (item_ == theItem);
}
@end