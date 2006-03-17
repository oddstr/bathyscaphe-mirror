//
//  $Id: CMROpenURLManager.m,v 1.4 2006/03/17 17:52:34 tsawada2 Exp $
//  BathyScaphe
//
//  Created by minamie on Sun Jan 25 2004.
//  Copyright (c) 2004 CocoMonar Project, (c) 2006 BathyScaphe Project. All rights reserved.
//

#import "CMROpenURLManager.h"
#import "CocoMonar_Prefix.h"
#import <Cocoa/Cocoa.h>

#import "CMRThreadLinkProcessor.h"
#import "CMRDocumentFileManager.h"
#import "CMRThreadDocument.h"

/* .nib file name */
#define kOpenURLControllerNib	@"CMROpenURL"

/* Input Panel */
@interface OpenURLController : NSWindowController
{
	IBOutlet NSTextField	*_textField;
}
- (NSURL *) askUserURL;
- (IBAction) ok : (id) sender;
- (IBAction) cancel : (id) sender;
@end



@implementation OpenURLController
- (id) init
{
	return [self initWithWindowNibName : kOpenURLControllerNib];
}
- (IBAction) ok : (id) sender { [NSApp stopModalWithCode : NSOKButton]; }
- (IBAction) cancel : (id) sender { [NSApp stopModalWithCode : NSCancelButton]; }

- (NSURL *) askUserURL
{	
	int				code;
	
	[self window];
	[_textField setStringValue:@""];
	[_textField selectText:self];
	code = [NSApp runModalForWindow : [self window]];
	
	[[self window] close];
	return (NSOKButton == code)
		? [NSURL URLWithString:[_textField stringValue]]
		: nil;
}
@end

@implementation CMROpenURLManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (NSURL *) askUserURL
{
	OpenURLController	*controller_;
	NSURL				*u;	
	
	controller_ = [[OpenURLController alloc] init];
	u = [controller_ askUserURL];
	
	if (u != nil) {
		[self openLocation : u];
	}
	[controller_ release];
	
	return u;
}

- (BOOL) openLocation : (NSURL *) url
{
	NSString		*boardName_;
	NSURL			*boardURL_;
	NSString		*filepath_;
	
	if ([[url scheme] isEqualToString : @"bathyscaphe"]) {
		NSString *host_ = [url host];
		NSString *path_ = [url path];
		
		url = [[[NSURL alloc] initWithScheme : @"http" host : host_ path : path_] autorelease];
	}

	if ([CMRThreadLinkProcessor parseThreadLink : url
									  boardName : &boardName_
									   boardURL : &boardURL_
									   filepath : &filepath_]) {
		CMRDocumentFileManager	*dm;
		NSDictionary			*contentInfo_;
		NSString				*datIdentifier_;
		
		dm = [CMRDocumentFileManager defaultManager];
		datIdentifier_ = [dm datIdentifierWithLogPath : filepath_];
		contentInfo_ = [NSDictionary dictionaryWithObjectsAndKeys : 
			[boardURL_ absoluteString],
			BoardPlistURLKey,
			boardName_, 
			ThreadPlistBoardNameKey,
			datIdentifier_, 
			ThreadPlistIdentifierKey,
			nil];
		
		[dm ensureDirectoryExistsWithBoardName:boardName_];
		return [CMRThreadDocument showDocumentWithContentOfFile : filepath_
													contentInfo : contentInfo_];
	} else {
		int		code;
		NSAlert	*alert_ = [[NSAlert alloc] init];
			
		[alert_ setMessageText : NSLocalizedStringFromTable(@"Could Not Open Title", [self className], nil)];
		[alert_ setInformativeText : [NSString stringWithFormat : NSLocalizedStringFromTable(@"Could Not Open Message", [self className], nil), 
																  [url absoluteString]]];
		[alert_ addButtonWithTitle : NSLocalizedStringFromTable(@"Open in Web Browser", [self className], nil)];
		[alert_ addButtonWithTitle : NSLocalizedStringFromTable(@"Cancel", [self className], nil)];

		code = [alert_ runModal];

		if (code == NSAlertFirstButtonReturn) {
			[[NSWorkspace sharedWorkspace] openURL : url];
		}
		
		[alert_ release];
	}
	
	return NO;
}


/* Support Service Menu */
- (void) _showAlertForViaService
{
	NSAlert *alert_;
	
	alert_ = [[NSAlert alloc] init];
	[alert_ setMessageText : NSLocalizedStringFromTable(@"Could Not Open Via Service Title", [self className], nil)];
	[alert_ setInformativeText : NSLocalizedStringFromTable(@"Could Not Open Via Service Message", [self className], nil)];
	[alert_ addButtonWithTitle : NSLocalizedStringFromTable(@"Cancel", [self className], nil)];
	
	[alert_ runModal];
	[alert_ release];
}

- (void) openURL : (NSPasteboard *) pboard
		userData : (NSString *) data
		   error : (NSString **) error
{
	NSArray		*types			= nil;
	NSString	*pboardString   = nil;
	NSURL		*u				= nil;
	
	[NSApp activateIgnoringOtherApps : YES];
	types = [pboard types];
	if ([types containsObject : NSStringPboardType] == NO) {
		*error = @"[pboard types] dosen't contain NSStringPboardType.";
	
		[self _showAlertForViaService];
		return;
	}
	pboardString = [pboard stringForType : NSStringPboardType];
	if (pboardString == nil) {
		*error = @"pboardString is nil.";
		
		[self _showAlertForViaService];
		return;
	}
	u = [NSURL URLWithString : pboardString];
	if (u == nil) {
		*error = @"Can't create NSURL from pboardString.";
		
		[self _showAlertForViaService];
		return;
	}

	[self openLocation : u];	
	return;
}
@end
