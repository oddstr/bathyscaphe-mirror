/**
  * $Id: CMRReplyController-ViewAccessor.m,v 1.3 2005/06/12 01:36:15 tsawada2 Exp $
  * 
  * CMRReplyController-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRReplyController_p.h"
#import "CMRLayoutManager.h"
#import "CMRTextView.h"
#import "AppDefaults.h"



@implementation CMRReplyController(View)
- (NSComboBox *) nameComboBox{ return _nameComboBox; }
- (NSTextField *) mailField { return _mailField; }
- (NSTextView *) textView { return _textView; }
- (NSScrollView *) scrollView { return _scrollView; }
- (NSButton *) sageButton { return _sageButton; }
- (NSButton *) deleteMailButton { return _deleteMailButton; }

+ (Class) toolbarDelegateImpClass 
{ 
	return [CMRReplyControllerTbDelegate class];
}
- (NSString *) statusLineFrameAutosaveName 
{
	return APP_REPLY_STATUSLINE_IDENTIFIER;
}



- (void) updateTextView
{
	NSTextView	*textView_ = [self textView];
	
	if (nil == textView_)
		return;
	
	[textView_ setFont : [[self document] replyTextFont]];
	[textView_ setTextColor : [[self document] replyTextColor]];
	
	
	// キャレットの色、変換中の色をテキストの色と同期
	/*
#if 0
	if ([CMRPref caretUsesTextColor]) {
		[textView_ setInsertionPointColor : [[self document] replyTextColor]];
		
		// たぶん、「ことえり」だけだと思うけど、
		// @"NSUnderlineColor"という属生名を使用していて、
		// こいつを使われると下線部がテキストの色にならない。
		// なので、違う属性辞書で置き換える。
		[textView_ setMarkedTextAttributes : 
			[NSDictionary dictionaryWithObjectsAndKeys :
				[NSNumber numberWithInt : 1],
				NSUnderlineStyleAttributeName,
				nil]];
	} else {
		[textView_ setInsertionPointColor : [NSColor blackColor]];
		[textView_ setMarkedTextAttributes : nil];
	}
#else
	
	if ([CMRPref caretUsesTextColor]) {
		[textView_ setInsertionPointColor : [[self document] replyTextColor]];
	}
	
#endif
*/
	if ([CMRPref replyBackgroundColor] != nil) {
		[textView_ setDrawsBackground : YES];
		[textView_ setBackgroundColor : [CMRPref replyBackgroundColor]];
		[[textView_ window] setOpaque : NO];
		[textView_ setNeedsDisplay : YES];
	}
}
- (void) setupScrollView
{
	NSScrollView	*scrollView_ = [self scrollView];

	[scrollView_ setBorderType : NSBezelBorder];
	[scrollView_ setHasHorizontalScroller : NO];
	[scrollView_ setHasVerticalScroller : YES];
}
- (void) setupTextView
{
	NSLayoutManager	*layout;
	NSTextContainer	*container;
	NSTextView		*view;
	NSRect			cFrame;
	
	[self setupScrollView];
	
	cFrame.origin = NSZeroPoint; 
	cFrame.size = [[self scrollView] contentSize];
	
	/* LayoutManager */
	layout = [[CMRLayoutManager alloc] init];
	[[[self document] textStorage] addLayoutManager : layout];
	[layout release];
	
	/* TextContainer */
	container = [[NSTextContainer alloc] initWithContainerSize : 
					NSMakeSize(NSWidth(cFrame), 1e7)];
	[layout addTextContainer : container];
	[container release];
	
	/* TextView */
	view = [[[CMRTextView alloc] initWithFrame : cFrame 
								 textContainer : container] autorelease];
	
	[view setMinSize : NSMakeSize(0.0, NSHeight(cFrame))];
	[view setMaxSize : NSMakeSize(1e7, 1e7)];
	[view setVerticallyResizable :YES];
	[view setHorizontallyResizable : NO];
	[view setAutoresizingMask : NSViewWidthSizable];
	
	[container setWidthTracksTextView : YES];
	
	[view setTypingAttributes : [[self document] textAttributes]];
	[view setAllowsUndo : YES];
	[view setEditable : YES];
	[view setSelectable : YES];
	[view setImportsGraphics : NO];
	[view setRichText : NO];
	
	[view setDelegate : self];
	
	
	_textView = view;
	[[self scrollView] setDocumentView : _textView];
	[self updateTextView];
}

// ウインドウ領域の調節
- (void) setupWindowFrameWithMessenger
{
	NSRect		windowFrame_;
	
	windowFrame_ = [[self document] windowFrame];
	if (NSEqualRects(NSZeroRect, windowFrame_)) {
		NSString	*fs;
		
		// デフォルトのウインドウ領域
		if ((fs = [CMRPref replyWindowDefaultFrameString]) != nil) 
			[[self window] setFrameFromString : fs];
		
	} else {
		[[self window] setFrame : windowFrame_
						display : YES];
	}
}
- (void) setupNameComboBox
{
	[[self nameComboBox] setStringValue : [[self document] name]];
	[[self nameComboBox] setDelegate : self];
	[[self nameComboBox] reloadData]; //これをしないとcomboBoxのリストが表示されないまま
}
- (void) setupButtons
{
	[[self sageButton] setEnabled : [self canInsertSage]];
	[[self deleteMailButton] setEnabled : [self canDeleteMail]];
	[[self mailField] setDelegate : self];
}
- (void) setupKeyLoops
{
	[[self nameComboBox] setNextKeyView : [self mailField]];
	[[self mailField] setNextKeyView : [self textView]];
	[[self textView] setNextKeyView : [self nameComboBox]];
	[[self window] setInitialFirstResponder : [self textView]];
	[[self window] makeFirstResponder : [self textView]];
}


/* Notification */
- (void) applicationUISettingsUpdated : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		AppDefaultsLayoutSettingsUpdatedNotification);
	[self updateTextView];
}
- (void) controlTextDidChange : (NSNotification *) aNotification
{
	UTILAssertNotificationName(
		aNotification,
		NSControlTextDidChangeNotification);
	
	if ([aNotification object] == [self mailField])
		[self setupButtons];
}
@end



@implementation CMRReplyController (ViewSetup)
- (void) setupStatusLine
{
	[super setupStatusLine];
	[[self statusLine] setBoardHistoryEnabled : NO];
	[[self statusLine] setThreadHistoryEnabled : NO];
	
	[[self statusLine] synchronizeHistoryTitleAndSelectedItem];
}


- (void) setupUIComponents
{
	[super setupUIComponents];

	[self setupWindowFrameWithMessenger];
	[self setupNameComboBox];
	[self setupButtons];
	[self setupTextView];
	[self setupKeyLoops];

	[[NSNotificationCenter defaultCenter]
			 addObserver : self
			    selector : @selector(applicationUISettingsUpdated:)
			        name : AppDefaultsLayoutSettingsUpdatedNotification
			      object : CMRPref];
	[self synchronizeDataFromMessenger];
}

// TextView Delegate
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
	if (aSelector == @selector(insertTab:)) { // tab
		[[self window] makeFirstResponder : [self nameComboBox]];
		return YES;
	}
	
	if (aSelector == @selector(insertBacktab:)) { // shift-tab
		[[self window] makeFirstResponder : [self mailField]];
		return YES;
	}
	
	return NO;
}

// comboBox (kotehan list) Delegate
- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [[CMRPref defaultKoteHanList] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index
{
    return [[CMRPref defaultKoteHanList] objectAtIndex:index];
}

- (unsigned int)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string
{
    return [[CMRPref defaultKoteHanList] indexOfObject: string];
}

- (NSString *) firstGenreMatchingPrefix:(NSString *)prefix
{
    NSString *string = nil;
    NSString *lowercasePrefix = [prefix lowercaseString];
    NSEnumerator *stringEnum = [[CMRPref defaultKoteHanList] objectEnumerator];
    while ((string = [stringEnum nextObject])) {
		if ([[string lowercaseString] hasPrefix: lowercasePrefix]) return string;
    }
    return nil;
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)inputString
{
    NSString *candidate = [self firstGenreMatchingPrefix: inputString];
    return (candidate ? candidate : inputString);
}
@end