//
//  CMRStatusLine.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/14.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@protocol CMRTask;
@class BSStatusLineView;

@interface CMRStatusLine : NSObject {
	NSString						*_identifier;
	id								_delegate;
	
	IBOutlet BSStatusLineView		*_statusLineView;
//	IBOutlet NSTextField			*_statusTextField;
	IBOutlet NSProgressIndicator	*_progressIndicator;
	IBOutlet NSObjectController		*_objectController;
}

- (id)initWithIdentifier:(NSString *)identifier;

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)anIdentifier;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

// Action
- (IBAction)cancel:(id)sender;

- (BSStatusLineView *)statusLineView;

- (void)setupUIComponents;
- (void)statusLineViewDidMoveToWindow;
- (void)updateUIComponentsOnTaskStarting;
- (void)updateUIComponentsOnTaskFinishing;
@end


@interface CMRStatusLine(Private)
//- (NSTextField *)statusTextField;
- (NSProgressIndicator *)progressIndicator;
- (NSObjectController *)taskObjectController;
@end
