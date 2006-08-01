#import "BSIPIAppKitExtensions.h"
#import <Carbon/Carbon.h>

#pragma mark Custom SubClass
@implementation BSIPISegmentedControlTbItem
- (id) delegate
{
	return _delegate;
}

- (void) setDelegate: (id) aDelegate
{
	_delegate = aDelegate;
}

- (void) validate
{
	id	segmentedControl_ = [self view];
	id	myDelegate = [self delegate];
	int	i, numOfSegments;

	if(!segmentedControl_)
		return;
	
	if(!myDelegate) {
		[segmentedControl_ setEnabled: NO];
		return;
	}

	if(![myDelegate respondsToSelector: @selector(segCtrlTbItem:validateSegment:)]) {
		[segmentedControl_ setEnabled: NO];
		return;
	}

	numOfSegments = [segmentedControl_ segmentCount];
	for(i=0; i < numOfSegments; i++) {
		BOOL	validation = [myDelegate segCtrlTbItem: self validateSegment: i];
		[segmentedControl_ setEnabled: validation forSegment: i];
	}
}

- (void) dealloc
{
	[self setDelegate: nil];
	[super dealloc];
}
@end

#pragma mark Category Extensions
@implementation NSCell(BSIPIExtensionFromSG)
- (void) setAttributesFromCell : (NSCell *) aCell
{
	if(nil == aCell) return;
	
	[self setType : [aCell type]];
	[self setState : [aCell state]];
	[self setTarget : [aCell target]];
	[self setAction : [aCell action]];
	[self setTag : [aCell tag]];
	[self setEnabled : [aCell isEnabled]];
	[self setContinuous : [aCell isContinuous]];
	[self setEditable : [aCell isEditable]];
	[self setSelectable : [aCell isSelectable]];
	[self setBordered : [aCell isBordered]];
	[self setBezeled : [aCell isBezeled]];
	[self setScrollable : [aCell isScrollable]];
	[self setAlignment : [aCell alignment]];
	[self setWraps : [aCell wraps]];
	[self setFont : [aCell font]];
	[self setEntryType : [aCell entryType]];
	[self setFormatter : [aCell formatter]];
	[self setObjectValue : [aCell objectValue]];
	[self setImage : [aCell image]];
	[self setRepresentedObject : [aCell representedObject]];
	[self setMenu : [aCell menu]];
	[self setSendsActionOnEndEditing : [aCell sendsActionOnEndEditing]];
	[self setRefusesFirstResponder : [aCell refusesFirstResponder]];
	[self setShowsFirstResponder : [aCell showsFirstResponder]];
	[self setMnemonicLocation : [aCell mnemonicLocation]];
	[self setAllowsEditingTextAttributes : [aCell allowsEditingTextAttributes]];
	[self setImportsGraphics : [aCell importsGraphics]];
	[self setAllowsMixedState : [aCell allowsMixedState]];
}
@end

@implementation NSWorkspace(BSIPIExtensionFromSG)
- (BOOL) _openURLsInBackGround : (NSArray *) URLsArray
{
	OSStatus			err;
	LSLaunchURLSpec inLaunchSpec;
	
	if(nil == URLsArray || 0 == [URLsArray count])
		return NO;
	
	inLaunchSpec.appURL = NULL;
	inLaunchSpec.itemURLs = (CFArrayRef )URLsArray;
	inLaunchSpec.passThruParams = nil;
	inLaunchSpec.launchFlags = kLSLaunchDontSwitch;
	inLaunchSpec.asyncRefCon = nil;

	err = LSOpenFromURLSpec( &inLaunchSpec, NULL );

	return (err == noErr);
}

- (BOOL) openURL : (NSURL *) url_ inBackGround : (BOOL) inBG
{
	if(url_ == nil) return NO;
	if(inBG) {
		NSArray	*tempArray_;
		tempArray_ = [NSArray arrayWithObject : url_];
		return [self _openURLsInBackGround : tempArray_];
	} else {
		return [self openURL : url_];
	}
	return NO;
}
@end
