/**
  * $Id: CMRReplyController-ViewAccessor.m,v 1.19 2007/11/11 08:49:44 tsawada2 Exp $
  * 
  * CMRReplyController-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRReplyController_p.h"
#import "AppDefaults.h"
#import <SGAppKit/BSReplyTextView.h>
#import <SGAppKit/BSLayoutManager.h>

static void *kReplySettingsContext = @"EternalBlaze";

@implementation CMRReplyController(View)
+ (Class)toolbarDelegateImpClass 
{ 
	return [CMRReplyControllerTbDelegate class];
}
- (NSString *)statusLineFrameAutosaveName 
{
	return APP_REPLY_STATUSLINE_IDENTIFIER;
}

#pragma mark Accessors

- (NSComboBox *) nameComboBox{ return _nameComboBox; }
- (NSTextField *) mailField { return _mailField; }
- (NSTextView *) textView { return _textView; }
- (NSScrollView *) scrollView { return _scrollView; }
- (NSButton *) sageButton { return _sageButton; }
- (NSButton *) deleteMailButton { return _deleteMailButton; }

#pragma mark UI SetUp

- (void)updateTextView
{
	BSReplyTextView	*textView_ = (BSReplyTextView *)[self textView];
	
	if (!textView_) return;

	[(BSLayoutManager *)[textView_ layoutManager] setShouldAntialias:[CMRPref shouldThreadAntialias]];
	[textView_ setNeedsDisplay:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kReplySettingsContext && object == CMRPref) {
		NSColor *newColor = [change objectForKey:NSKeyValueChangeNewKey];
		NSTextView *textView = [self textView];
		if (!newColor) {
			NSLog(@"Warning! -[observeValueForKeyPath:ofObject:change:context:] color is nil.");
			return;
		}
		if ([keyPath isEqualToString:@"threadViewTheme.replyColor"]) {
			[textView setTextColor:newColor];
			[textView setInsertionPointColor:newColor];
		} else if ([keyPath isEqualToString:@"threadViewTheme.replyBackgroundColor"]) {
			[textView setBackgroundColor:newColor];
		}
		[textView setNeedsDisplay:YES];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)setupScrollView
{
	NSScrollView	*scrollView_ = [self scrollView];

	[scrollView_ setBorderType:NSNoBorder];
	[scrollView_ setHasHorizontalScroller:NO];
	[scrollView_ setHasVerticalScroller:YES];
}

- (void)setupTextView
{
	NSLayoutManager	*layout;
	NSTextContainer	*container;
	NSTextView		*view;
	NSRect			cFrame;
	BSThreadViewTheme *theme;
	
	[self setupScrollView];
	
	cFrame.origin = NSZeroPoint; 
	cFrame.size = [[self scrollView] contentSize];
	
	/* LayoutManager */
	layout = [[BSLayoutManager alloc] init];
	[[[self document] textStorage] addLayoutManager:layout];
	[layout release];

	/* TextContainer */
	container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(NSWidth(cFrame), FLT_MAX)];
	[layout addTextContainer:container];
	[container release];

	/* TextView */
	view = [[[BSReplyTextView alloc] initWithFrame:cFrame textContainer:container] autorelease];

	[view setMinSize:NSMakeSize(0.0, NSHeight(cFrame))];
	[view setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[view setVerticallyResizable:YES];
	[view setHorizontallyResizable:NO];
	[view setAutoresizingMask:NSViewWidthSizable];

	[container setWidthTracksTextView:YES];

	[view setTypingAttributes:[[self document] textAttributes]];
	[view setAllowsUndo:YES];
	[view setEditable:YES];
	[view setSelectable:YES];
	[view setImportsGraphics:NO];
	[view setRichText:NO];

	theme = [CMRPref threadViewTheme];
	[view setTextColor:[theme replyColor]];
	[view setInsertionPointColor:[theme replyColor]];

	[view setDelegate:self];

	_textView = view;
	[[self scrollView] setDocumentView:_textView];

	[view setDrawsBackground:YES];
	[view setBackgroundColor:[theme replyBackgroundColor]];
	[self updateTextView];

	[view bind:@"font" toObject:CMRPref withKeyPath:@"threadViewTheme.replyFont" options:nil];

	// textColor だけ変えるなら KVB でも良いが、一緒に insertionPointColor も
	// 変えたいので、KVO で行くことにする。
	[CMRPref addObserver:self
			  forKeyPath:@"threadViewTheme.replyColor"
				 options:NSKeyValueObservingOptionNew
				 context:kReplySettingsContext];
	[CMRPref addObserver:self
			  forKeyPath:@"threadViewTheme.replyBackgroundColor"
			     options:NSKeyValueObservingOptionNew
				 context:kReplySettingsContext];
}

- (void)setupWindowFrameWithMessenger
{
	NSRect		windowFrame_;
	
	windowFrame_ = [[self document] windowFrame];
	if (NSEqualRects(NSZeroRect, windowFrame_)) {
		NSString	*fs;
		
		if (fs = [CMRPref replyWindowDefaultFrameString]) 
			[[self window] setFrameFromString:fs];
	} else {
		[[self window] setFrame:windowFrame_ display:YES];
	}
	
	[[self window] useOptimizedDrawing:YES];
}

- (void)setupNameComboBox
{
	[[self nameComboBox] setStringValue:[[self document] name]];
	[[self nameComboBox] reloadData];
}

- (void)setupButtons
{
	[[self sageButton] setEnabled:[self canInsertSage]];
	[[self deleteMailButton] setEnabled:[self canDeleteMail]];
}

- (void)setupKeyLoops
{
	[[self nameComboBox] setNextKeyView:[self mailField]];
	[[self mailField] setNextKeyView:[self textView]];
	[[self textView] setNextKeyView:[self nameComboBox]];
	[[self window] setInitialFirstResponder:[self textView]];
	[[self window] makeFirstResponder:[self textView]];
}

- (void) setupUIComponents
{
	[super setupUIComponents];

	[self setupWindowFrameWithMessenger];
	[self setupNameComboBox];
	[self setupButtons];
	[self setupTextView];
	[self setupKeyLoops];

	[[m_templateInsertionButton cell] setUsesItemFromMenu:YES];

	[[NSNotificationCenter defaultCenter]
			 addObserver:self
			    selector:@selector(applicationUISettingsUpdated:)
			        name:AppDefaultsLayoutSettingsUpdatedNotification
			      object:CMRPref];
	[self synchronizeDataFromMessenger];
}
@end


@implementation CMRReplyController (Delegate)
#pragma mark Notification
- (void)applicationUISettingsUpdated:(NSNotification *)notification
{
	UTILAssertNotificationName(
		notification,
		AppDefaultsLayoutSettingsUpdatedNotification);
	[self updateTextView];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	UTILAssertNotificationName(
		aNotification,
		NSControlTextDidChangeNotification);
	
	if ([aNotification object] == [self mailField]) [self setupButtons];
}

#pragma mark NSTextView Delegate
- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
	if (aSelector == @selector(insertTab:)) { // tab
		[[self window] makeFirstResponder:[self nameComboBox]];
		return YES;
	}
	
	if (aSelector == @selector(insertBacktab:)) { // shift-tab
		[[self window] makeFirstResponder:[self mailField]];
		return YES;
	}
	
	return NO;
}

// GrafEisen Addition
/* 2006-02-28 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	NSDocument を "dirty" な状態にするのは、通常 NSDocument 自身に任せておけばよいはず。
	しかし、「下書きとして保存」した後、本文を追加／削除などして編集しても、"dirty" な状態になぜか
	なってくれない。テキストを選択して、削除したりすると "dirty" になるのだが…
	そこでこの delegate でテキストの追加／削除をつかまえ、強制的に "dirty" フラグを立てる。
	単純な状況で試す限り良い感じで動くようだが、しばらく様子見が必要か。
*/
- (void)textDidChange:(NSNotification *)aNotification
{
	if(NO == [[self document] isDocumentEdited]) // "dirty" でないときのみ updateChangeCount: する。
		[[self document] updateChangeCount:NSChangeDone];
}

#pragma mark NSComboBoxDataSource
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
    return [[CMRPref defaultKoteHanList] indexOfObject:string];
}

- (NSString *)firstGenreMatchingPrefix:(NSString *)prefix
{
    NSString *string = nil;
    NSString *lowercasePrefix = [prefix lowercaseString];
    NSEnumerator *stringEnum = [[CMRPref defaultKoteHanList] objectEnumerator];
    while ((string = [stringEnum nextObject])) {
		if ([[string lowercaseString] hasPrefix:lowercasePrefix]) return string;
    }
    return nil;
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)inputString
{
    NSString *candidate = [self firstGenreMatchingPrefix:inputString];
    return (candidate ? candidate : inputString);
}
@end
