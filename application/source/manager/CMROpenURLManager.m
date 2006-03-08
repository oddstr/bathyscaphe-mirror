//
//  $Id: CMROpenURLManager.m,v 1.2 2006/03/08 10:46:48 tsawada2 Exp $
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
	int				code;
	
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
		code = NSRunAlertPanel(NSLocalizedStringFromTable(@"Could Not Open Title",
														  [self className],
														  nil),
							   [NSString stringWithFormat:
								   NSLocalizedStringFromTable(@"Could Not Open Message",
															  [self className],
															  nil), 
								   [url absoluteString]],
							   NSLocalizedStringFromTable(@"Open in Web Browser",
														  [self className],
														  nil), 
							   NSLocalizedStringFromTable(@"Cancel",
														  [self className],
														  nil), 
							   NULL);
		if ( code == NSAlertDefaultReturn ) {
			[[NSWorkspace sharedWorkspace] openURL : url];
		}
	}
	
	return NO;
}


/* Support Service Menu */
- (void)openURL:(NSPasteboard *)pboard
	   userData:(NSString *)data
		  error:(NSString **)error
{
	NSArray		*types			= nil;
	NSString	*pboardString  = nil;
	NSURL		*u				= nil;
	
	[NSApp activateIgnoringOtherApps:YES];
	types = [pboard types];
	if ( [types containsObject:NSStringPboardType] == NO ) {
		NSLog(@"types dosen't countain NSStringPboardType\n");
		NSRunAlertPanel(NSLocalizedStringFromTable(@"Could Not Open Title",
												   [self className],
												   nil),
						[NSString stringWithFormat:
							NSLocalizedStringFromTable(@"Could Not Open Message",
													   [self className],
													   nil), 
							@""],
						NSLocalizedStringFromTable(@"OK",
												   [self className],
												   nil), 
						NSLocalizedStringFromTable(@"Cancel",
												   [self className],
												   nil), 
						NULL);
		return;
	}
	pboardString = [pboard stringForType:NSStringPboardType];
	if ( pboardString == nil ) {
		NSLog(@"pboardString == nil\n");
		NSRunAlertPanel(NSLocalizedStringFromTable(@"Could Not Open Title",
												   [self className],
												   nil),
						[NSString stringWithFormat:
							NSLocalizedStringFromTable(@"Could Not Open Message",
													   [self className],
													   nil), 
							@""],
						NSLocalizedStringFromTable(@"OK",
												   [self className],
												   nil), 
						NSLocalizedStringFromTable(@"Cancel",
												   [self className],
												   nil), 
						NULL);
		return;
	}
	u = [NSURL URLWithString:pboardString];
	if ( u == nil) {
		NSLog(@"u == nil\n");
		NSRunAlertPanel(NSLocalizedStringFromTable(@"Could Not Open Title",
												   [self className],
												   nil),
						[NSString stringWithFormat:
							NSLocalizedStringFromTable(@"Could Not Open Message",
													   [self className],
													   nil), 
							pboardString],
						NSLocalizedStringFromTable(@"OK",
												   [self className],
												   nil), 
						NSLocalizedStringFromTable(@"Cancel",
												   [self className],
												   nil), 
						NULL);
		return;
	}
	[self openLocation : u];
	
	return;
}

@end
