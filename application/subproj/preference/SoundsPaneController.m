//
//  $Id: SoundsPaneController.m,v 1.1 2006/01/27 17:52:53 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/27.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "SoundsPaneController.h"

#import "AppDefaults.h"
#import "PreferencePanes_Prefix.h"

@implementation SoundsPaneController
static BOOL addFileListsToMenu(NSMenu *menu_, short ofWhichDomain)
{
    CFURLRef        soundsFolderURL;
    FSRef           soundsFolderRef;
    CFStringRef     soundsFolderPath;
    OSErr           err;
	NSDirectoryEnumerator	*tmpEnum;
	NSString		*file;
    NSFileManager   *mgr = [NSFileManager defaultManager];
	NSArray			*anArray = [NSSound soundUnfilteredFileTypes];
	BOOL			actuallyAdded = NO;

    err = FSFindFolder(ofWhichDomain, kSystemSoundsFolderType, kDontCreateFolder, &soundsFolderRef);
    if (err == noErr) {
		soundsFolderURL = CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &soundsFolderRef);
		if (soundsFolderURL) {
			soundsFolderPath = CFURLCopyFileSystemPath (soundsFolderURL, kCFURLPOSIXPathStyle);
			if (soundsFolderPath) {
				tmpEnum = [mgr enumeratorAtPath : (NSString *)soundsFolderPath];

				while (file = [tmpEnum nextObject]) {
					if ([anArray containsObject : [file pathExtension]]) {
						[menu_ addItemWithTitle : [file stringByDeletingPathExtension]
										 action : @selector(soundChosen:)
								  keyEquivalent : @""];
						actuallyAdded = YES;
					}
				}

				CFRelease(soundsFolderPath);
			}
			CFRelease(soundsFolderURL);
		}
	}
	
	return actuallyAdded;
}

- (void) setUpMenu : (NSMenu *) menu_
{
	int		itemCount_;

	addFileListsToMenu(menu_, kSystemDomain);
	itemCount_ = [menu_ numberOfItems];
	if(addFileListsToMenu(menu_, kLocalDomain))
		[menu_ insertItem : [NSMenuItem separatorItem] atIndex : itemCount_];

	itemCount_ = [menu_ numberOfItems];
	if(addFileListsToMenu(menu_, kUserDomain))
		[menu_ insertItem : [NSMenuItem separatorItem] atIndex : itemCount_];
		
	[[self soundForHEADCheckNewArrivedBtn] setMenu : menu_];
	[[[self soundForHEADCheckNewArrivedBtn] menu] setTitle : @"setHEADCheckNewArrivedSound:"];

	[[self soundForHEADCheckNoUpdateBtn] setMenu : [menu_ copy]];
	[[[self soundForHEADCheckNoUpdateBtn] menu] setTitle : @"setHEADCheckNoUpdateSound:"];

	[[self soundForReplyDidFinishBtn] setMenu : [menu_ copy]];
	[[[self soundForReplyDidFinishBtn] menu] setTitle : @"setReplyDidFinishSound:"];
}

#pragma mark Accessors
- (NSPopUpButton *) soundForHEADCheckNewArrivedBtn
{
	return _soundForHEADCheckNewArrivedBtn;
}
- (NSPopUpButton *) soundForHEADCheckNoUpdateBtn
{
	return _soundForHEADCheckNoUpdateBtn;
}
- (NSPopUpButton *) soundForReplyDidFinishBtn
{
	return _soundForReplyDidFinishBtn;
}
- (NSMenu *) soundsListMenu
{
	return _soundsListMenu;
}

#pragma mark IBActions
- (IBAction) soundChosen : (id) sender
{
	NSString		*title_ = [(NSMenuItem *)sender title];
	NSSound			*sound_ = [NSSound soundNamed : title_];
	[sound_ play];
	[[self preferences] performSelector : NSSelectorFromString([[(NSMenuItem *)sender menu] title])
							 withObject : title_
							 afterDelay : 0];
}

- (IBAction) soundNone : (id) sender
{
	[[self preferences] performSelector : NSSelectorFromString([[(NSMenuItem *)sender menu] title])
							 withObject : @""
							 afterDelay : 0];
}

#pragma mark Private Methods

- (NSString *) mainNibName
{
	return @"SoundsPane";
}

- (void) updateUIComponents
{
	NSString *tmp_;

	tmp_ = [[self preferences] HEADCheckNewArrivedSound];
	if([tmp_ isEqualToString : @""])
		[[self soundForHEADCheckNewArrivedBtn] selectItemAtIndex : 0];
	else
		[[self soundForHEADCheckNewArrivedBtn] selectItemWithTitle : tmp_];
	[[self soundForHEADCheckNewArrivedBtn] synchronizeTitleAndSelectedItem];

	tmp_ = [[self preferences] HEADCheckNoUpdateSound];
	if([tmp_ isEqualToString : @""])
		[[self soundForHEADCheckNoUpdateBtn] selectItemAtIndex : 0];
	else
		[[self soundForHEADCheckNoUpdateBtn] selectItemWithTitle : tmp_];
	[[self soundForHEADCheckNoUpdateBtn] synchronizeTitleAndSelectedItem];

	tmp_ = [[self preferences] replyDidFinishSound];
	if([tmp_ isEqualToString : @""])
		[[self soundForReplyDidFinishBtn] selectItemAtIndex : 0];
	else
		[[self soundForReplyDidFinishBtn] selectItemWithTitle : tmp_];
	[[self soundForReplyDidFinishBtn] synchronizeTitleAndSelectedItem];
}

- (void) setupUIComponents
{
	if (nil == _contentView)
		return;

	[self setUpMenu : [self soundsListMenu]];
	[self updateUIComponents];
}


@end

@implementation SoundsPaneController(Toolbar)
- (NSString *) identifier
{
	return PPSoundsPreferencesIdentifier;
}
- (NSString *) helpKeyword
{
	return PPLocalizedString(@"Help_Sounds");
}
- (NSString *) label
{
	return PPLocalizedString(@"Sounds Label");
}
- (NSString *) paletteLabel
{
	return PPLocalizedString(@"Sounds Label");
}
- (NSString *) toolTip
{
	return PPLocalizedString(@"Sounds ToolTip");
}
- (NSString *) imageName
{
	return @"Sounds";
}
@end
