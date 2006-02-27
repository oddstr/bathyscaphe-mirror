/**
  * $Id: CMRReplyController-ViewAccessor.m,v 1.8 2006/02/27 20:21:20 tsawada2 Exp $
  * 
  * CMRReplyController-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRReplyController_p.h"
#import "CMRLayoutManager.h"
#import "AppDefaults.h"


@implementation CMRReplyController(View)
+ (Class) toolbarDelegateImpClass 
{ 
	return [CMRReplyControllerTbDelegate class];
}
- (NSString *) statusLineFrameAutosaveName 
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

- (void) updateTextView
{
	NSTextView	*textView_ = [self textView];
	NSColor		*bgColor_ = [CMRPref replyBackgroundColor];
	
	if (nil == textView_)
		return;
	
	[textView_ setFont : [[self document] replyTextFont]];
	[textView_ setTextColor : [[self document] replyTextColor]];

	if (bgColor_ != nil) {		
		[textView_ setDrawsBackground : YES];
		[textView_ setBackgroundColor : [bgColor_ colorWithAlphaComponent : [CMRPref replyBgAlphaValue]]];
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
	view = [[[NSTextView alloc] initWithFrame : cFrame 
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

// �E�C���h�E�̈�̒���
- (void) setupWindowFrameWithMessenger
{
	NSRect		windowFrame_;
	
	windowFrame_ = [[self document] windowFrame];
	if (NSEqualRects(NSZeroRect, windowFrame_)) {
		NSString	*fs;
		
		// �f�t�H���g�̃E�C���h�E�̈�
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
	[[self nameComboBox] reloadData]; //��������Ȃ���comboBox�̃��X�g���\������Ȃ��܂�
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

- (void) setupStatusLine
{
	[super setupStatusLine];
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
@end

#pragma mark -

@implementation CMRReplyController (Delegate)
#pragma mark Notification
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

#pragma mark NSTextView Delegate
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

// GrafEisen Addition
/* 2006-02-28 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	NSDocument �� "dirty" �ȏ�Ԃɂ���̂́A�ʏ� NSDocument ���g�ɔC���Ă����΂悢�͂��B
	�������A�u�������Ƃ��ĕۑ��v������A�{����ǉ��^�폜�Ȃǂ��ĕҏW���Ă��A"dirty" �ȏ�ԂɂȂ���
	�Ȃ��Ă���Ȃ��B�e�L�X�g��I�����āA�폜�����肷��� "dirty" �ɂȂ�̂����c
	�����ł��� delegate �Ńe�L�X�g�̒ǉ��^�폜�����܂��A�����I�� "dirty" �t���O�𗧂Ă�B
	�P���ȏ󋵂Ŏ�������ǂ������œ����悤�����A���΂炭�l�q�����K�v���B
*/
- (void)textDidChange:(NSNotification *)aNotification
{
	//NSLog(@"text did change");
	if(NO == [[self document] isDocumentEdited]) // "dirty" �łȂ��Ƃ��̂� updateChangeCount: ����B
		[[self document] updateChangeCount:NSChangeDone];
}

#pragma mark NSComboBox Delegate
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