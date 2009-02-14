//
//  CMRStatusLine.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/14.
//  Copyright 2005-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@protocol CMRTask;
@class BSStatusLineView;

@interface CMRStatusLine : NSObject {
//	NSString						*_identifier;
	id								_delegate;
	
	IBOutlet BSStatusLineView		*_statusLineView;
	IBOutlet NSProgressIndicator	*_progressIndicator;
	IBOutlet NSObjectController		*_objectController;
}

//- (id)initWithIdentifier:(NSString *)identifier;
- (id)initWithDelegate:(id)delegate;

//- (NSString *)identifier;
//- (void)setIdentifier:(NSString *)anIdentifier;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

// Action
- (IBAction)cancel:(id)sender;

- (BSStatusLineView *)statusLineView;
- (NSProgressIndicator *)progressIndicator;
- (NSObjectController *)taskObjectController;

- (void)setupUIComponents;
- (void)statusLineViewDidMoveToWindow;
- (void)statusLineWillRemoveFromWindow;
@end
