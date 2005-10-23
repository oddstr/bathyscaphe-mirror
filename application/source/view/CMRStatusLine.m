/**
  * $Id: CMRStatusLine.m,v 1.6 2005/10/23 09:15:39 tsawada2 Exp $
  * 
  * CMRStatusLine.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine.h"

#import "CMRTask.h"
#import "CMRTaskManager.h"
#import "missing.h"
#import "RBSplitView.h"

#define kLoadNibName				@"CMRStatusView"

static NSString *const CMRStatusLineShownKey = @"Status Line Visibility";

@implementation CMRStatusLine
- (id) initWithIdentifier : (NSString *) identifier
{
	if(self = [super init]){
		[self setIdentifier : identifier];
		if(NO == [NSBundle loadNibNamed : kLoadNibName
								  owner : self]){
			[self release];
			return nil;
		}
		[self registerToNotificationCenter];
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupUIComponents];
	[self updateStatusLineWithTask : nil];
}
- (void) dealloc
{
	[self setWindow : nil];
	[self removeFromNotificationCenter];

	[_identifier release];
	
	// nib
	[_statusLineView release];
	
	[super dealloc];
}

#pragma mark Accessor

- (NSView *) statusLineView
{
    return _statusLineView;
}
- (NSTextField *) statusTextField
{
    return _statusTextField;
}
- (NSProgressIndicator *) progressIndicator
{
    return _progressIndicator;
}

- (NSWindow *) window
{
	return _window;
}

- (NSString *) identifier
{
	return _identifier;
}
- (void) setIdentifier : (NSString *) anIdentifier
{
	id tmp;
	
	tmp = _identifier;
	_identifier = [anIdentifier retain];
	[tmp release];
}

- (id) delegate
{
	return _delegate;
}
- (void) setDelegate : (id) aDelegate
{
	_delegate = aDelegate;
}

#pragma mark Window

- (void) setWindow : (NSWindow *) aWindow
{
	[self setWindow : aWindow
			visible : [[self preferencesObject] 
						  boolForKey : [self statusLineShownUserDefaultsKey]
						defaultValue : YES]];
}
- (void) setWindow : (NSWindow *) aWindow
		   visible : (BOOL      ) shown
{
	_window = aWindow;
	if(nil == _window) return;
	
	[self setVisible:shown animate:NO];
}

- (void) changeWindowFrame : (NSWindow *) aWindow
                   animate : (BOOL      ) animateFlag
           statusLineShown : (BOOL      ) willBeShown
{
	NSRect		windowFrame_  = [aWindow frame];
	NSRect		lineFrame_    = [[self statusLineView] frame];
	float		statusBarHeight_;
	
	if(willBeShown){
		
		// �E�B���h�E�̉����ɃX�e�[�^�X�o�[��z�u���邪�A���̍�
		// �E�B���h�E�̃��T�C�Y�����������
		// resize indicator�̃T�C�Y��������Ȃ��̂�
		// NSScroller�̕��ő�p
		lineFrame_.size.width = windowFrame_.size.width;
		lineFrame_.size.width -= [NSScroller scrollerWidth];
		
		lineFrame_.origin = NSZeroPoint;
		
		[[self statusLineView] setFrame : lineFrame_];
	}

	// �r���[�́u���E���v���d�Ȃ��đ����Ȃ�Ȃ��悤�ɁA1�s�N�Z���]���ɏo�����ꂷ��
	statusBarHeight_ = NSHeight(lineFrame_)+1 ;
	
	{
		NSEnumerator	*iter_;
		NSView			*view_;
		
		iter_ = [[[[self window] contentView] subviews] objectEnumerator];
		while(view_ = [iter_ nextObject]){
			NSRect		newRect;

			if(view_ == [self statusLineView]) continue;
			
			if (willBeShown) {
				// �ŉ����ɐڂ��Ĕz�u����Ă���r���[�� height ���k�߂ĉ����ɗ]�������A������
				// �X�e�[�^�X�o�[���������ނƍl����i�E�C���h�E���̂̃T�C�Y�͕ς��Ȃ��j�B
				if([view_ frame].origin.y <= 0) {

					float tmp_ = 0.0;
				
					if([view_ class] == [RBSplitView class]) {
						// RBSplitView �̃��T�C�Y���̕s�R�ȋ����΍�BRBSplitView �� frame ��
						// �ύX����O�ɁARBSplitSubview �� dimension�i���j���L�����Ă����A
						// frame �ύX��ɂ��� dimension �ɍĐݒ肵�Ă��B
						tmp_ = [[(RBSplitView *)view_ subviewWithIdentifier : @"boards"] dimension];
					}
					
					newRect = [view_ frame];
					newRect.origin.y += statusBarHeight_;
					newRect.size.height -= statusBarHeight_;
					[view_ setFrame : newRect];
					
					if([view_ class] == [RBSplitView class]) {
						[[(RBSplitView *)view_ subviewWithIdentifier : @"boards"] setDimension : tmp_];
					}
				}

			} else {
			
				// �X�e�[�^�X�o�[���悯�Ĕz�u����Ă����r���[�� height ���g�債�āA�ŉ����ɐڒn������B

				if([view_ frame].origin.y <= statusBarHeight_) {
					newRect = [view_ frame];
					newRect.origin.y -= statusBarHeight_;
					newRect.size.height += statusBarHeight_;
					[view_ setFrame : newRect];
				}
			}
		}
	}
	
	//[aWindow displayIfNeeded];	// �����K�v�Ȃ�
}

- (BOOL) isVisible
{
	return ([[self statusLineView] window] != nil);
}

- (void) setVisible : (BOOL) shown
            animate : (BOOL) isAnimate
{
	if(shown == [self isVisible]) return;
	
	if(NO == [self isVisible]){
		[[[self window] contentView] addSubview : [self statusLineView]];
	}else{
		[[self statusLineView] removeFromSuperviewWithoutNeedingDisplay];
	}
	[self changeWindowFrame : [self window]
					animate : isAnimate
			statusLineShown : [self isVisible]];
	
	// User Defaults
	[[NSUserDefaults standardUserDefaults] 
			setBool : [self isVisible]
			 forKey : [self statusLineShownUserDefaultsKey]];
}

- (void) setInfoText : (id) aText;
{
    id        v = aText;
    
    if (nil == v || NO == [v isKindOfClass : [NSAttributedString class]]) {
        [[self statusTextField] setObjectValue : nil == v ? @"" : v];
        return;
    }

    [[self statusTextField] setAttributedStringValue : v];
}

#pragma mark IBAction

- (IBAction) cancel : (id) sender
{
	[[CMRTaskManager defaultManager] cancel : sender];
}
- (IBAction) toggleStatusLineShown : (id) sender
{
	[self setVisible:(NO == [self isVisible]) animate:YES];
}

#pragma mark User Defaults

- (NSString *) userDefaultsKeyWithKey : (NSString *) key
{
	if(nil == key || nil == [self identifier])
		return key;
	
	return [NSString stringWithFormat :
						@"%@ %@",
						[self identifier],
						key];
}
- (NSString *) statusLineShownUserDefaultsKey
{
	return [self userDefaultsKeyWithKey : CMRStatusLineShownKey];
}
- (id) preferencesObject
{
	return [NSUserDefaults standardUserDefaults];
}

#pragma mark Other Actions

- (void) setupUIComponents
{
    unsigned    autoresizingMask_;

    autoresizingMask_ = NSViewMaxYMargin;
    autoresizingMask_ |= NSViewWidthSizable;
    [[self statusLineView] setAutoresizingMask : autoresizingMask_];
}

- (void) updateStatusLineWithTask : (id<CMRTask>) aTask;
{

    if (NO == [[CMRTaskManager defaultManager] isInProgress]) {
        [[self progressIndicator] stopAnimation : nil];
        [[self statusTextField] setStringValue : @""];
        
    } else {
        [[self progressIndicator] startAnimation : nil];
        [[self statusTextField] setStringValue : ([aTask message] ? [aTask message] : @"")];
    }
}
@end

#pragma mark -

@implementation CMRStatusLine(Notification)
- (void) registerToNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillStartNotification:)
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillProgressNotification:)
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskDidFinishNotification:)
                name : CMRTaskDidFinishNotification
              object : nil];
    
    [super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskDidFinishNotification
              object : nil];

    [super removeFromNotificationCenter];
}


- (void) taskWillStartNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillStartNotification);

    [self updateStatusLineWithTask : [theNotification object]];
}
- (void) taskWillProgressNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillProgressNotification);
    
    [self updateStatusLineWithTask : [theNotification object]];
}

- (void) taskDidFinishNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskDidFinishNotification);
    UTILAssertConformsTo(
        [[theNotification object] class],
        @protocol(CMRTask));
    
    [self updateStatusLineWithTask : [theNotification object]];
}
@end
