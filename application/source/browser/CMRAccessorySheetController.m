//:CMRAccessorySheetController.m
/**
  *
  * @see BoardManager.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/27  6:07:53 PM)
  *
  */
#import "CMRAccessorySheetController_p.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ íËêîÇ‚É}ÉNÉçíuä∑ ] //////////////////////////
//////////////////////////////////////////////////////////////////////
static NSString *const CMRAccessorySheetControllerWindowNibName = @"CMRAccessorySheet";

static NSString *const kContextInfoDelegateKey	= @"delegate";
static NSString *const kContextInfoObjectKey	= @"object";

@implementation CMRAccessorySheetController
- (id) initWithContentSize : (NSSize	  ) cSize
			  resizingMask : (unsigned int) mask
{
	if(self = [self init]){
		NSSize		size_;
		NSSize		minSize_;
		NSSize		maxSize_;
		NSWindow	*sheet_;
		
		[self setContentSize : cSize];
		
		sheet_ = [self window];
		size_ = [[sheet_ contentView] bounds].size;
		minSize_ = [sheet_ minSize];
		maxSize_ = [sheet_ maxSize];
		if(NO == (NSViewWidthSizable & mask)){
			minSize_.width = size_.width;
			maxSize_.width = size_.width;
		}
		if(NO == (NSViewHeightSizable & mask)){
			minSize_.height = size_.height;
			maxSize_.height = size_.height;
		}
		
		[sheet_ setMinSize : minSize_];
		[sheet_ setMaxSize : maxSize_];
		
		if (NSViewNotSizable == mask) [[self window] setShowsResizeIndicator : NO];
	}
	return self;
}
- (id) init
{
	if(self = [self initWithWindowNibName : CMRAccessorySheetControllerWindowNibName]){
	}
	return self;
}

- (void) dealloc
{
	[m_originalContentView release];
	[super dealloc];
}
// Window Management
- (void) windowDidLoad
{
	[super windowDidLoad];
	[self setupUIComponents];
}
@end



@implementation CMRAccessorySheetController(Private)
- (void) sheetDidEnd : (NSWindow *) sheet
		  returnCode : (int       ) returnCode
		 contextInfo : (void     *) contextInfo
{
	NSDictionary	*infoDict_;
	id				delegate_;
	id				userInfo_;
	NSView			*contentView_;
	SEL				sel_;
	
	infoDict_ = (NSDictionary *)contextInfo;
	UTILAssertKindOfClass(infoDict_, NSDictionary);
	
	sel_ = @selector(controller:sheetDidEnd:contentView:contextInfo:);
	delegate_ = [infoDict_ objectForKey : kContextInfoDelegateKey];
	userInfo_ = [infoDict_ objectForKey : kContextInfoObjectKey];
	
	[infoDict_ autorelease];
	[sheet close];
	
	contentView_ = [[self contentView] retain];
	[self setContentView : [self originalContentView]];
	if(delegate_ != nil && [delegate_ respondsToSelector : sel_]){
		[delegate_ controller : self
				  sheetDidEnd : sheet 
				  contentView : contentView_
				  contextInfo : userInfo_];
	}
	[contentView_ release];
}
@end



@implementation CMRAccessorySheetController(Content)
- (NSView *) contentView
{
	return m_contentView;
}
- (void) setContentView : (NSView *) aView
{
	unsigned		autoresizingMask_;
	
	[aView retain];
	
	[aView removeFromSuperview];
	[aView setFrame : [[self contentView] frame]];
	
	autoresizingMask_ = [[self originalContentView] autoresizingMask];
	[[self contentView] setAutoresizingMask : autoresizingMask_];
	
	[[[self window] contentView] 
			replaceSubview : [self contentView]
					  with : aView];
	
	m_contentView = aView;
	autoresizingMask_ = [aView autoresizingMask];
	[aView setAutoresizingMask : (NSViewHeightSizable | NSViewWidthSizable)];
	[[self originalContentView] setAutoresizingMask : autoresizingMask_];
	
	[aView release];
}
- (void) setContentSize : (NSSize) cSize
{
	float	width_;
	float	height_;
	NSSize	size_;
	NSView	*cView_;
		
	[self window];
	size_ = [[self contentView] bounds].size;
	
	width_ = cSize.width - size_.width;
	height_ = cSize.height - size_.height;
	
	cView_ = [[self window] contentView];
	size_ = [cView_ bounds].size;
	
	size_.width += width_;
	size_.height += height_;
	
	[cView_ setAutoresizesSubviews : YES];
	[[self window] setContentSize : size_];
}
- (void) beginSheetModalForWindow : (NSWindow *) docWindow
					modalDelegate : (id        ) modalDelegate
					  contentView : (NSView   *) contentView
					  contextInfo : (id		   ) info;
{
	NSMutableDictionary		*info_;
	
	info_ = [NSMutableDictionary dictionary];
	[info_ setNoneNil:modalDelegate forKey:kContextInfoDelegateKey];
	[info_ setNoneNil:info forKey:kContextInfoObjectKey];
	[self window];
	[self setContentView : contentView];
	
	[NSApp beginSheet : [self window]
	   modalForWindow : docWindow
		modalDelegate : self
	   didEndSelector : @selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo : [info_ retain]];
}
@end


@implementation CMRAccessorySheetController(Action)
- (IBAction) close : (id) sender
{
	[NSApp endSheet : [self window]
		 returnCode : NSOKButton];
}
@end
