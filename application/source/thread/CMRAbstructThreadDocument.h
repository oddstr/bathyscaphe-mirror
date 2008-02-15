//
//  CMRAbstructThreadDocument.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/14.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@class CMRThreadAttributes;
@class BSRelativeKeywordsCollector;

@interface CMRAbstructThreadDocument : NSDocument {
	CMRThreadAttributes			*_threadAttributes;
	NSTextStorage				*_textStorage;
	NSArray						*m_keywords;
	BSRelativeKeywordsCollector	*m_collector;
}

- (CMRThreadAttributes *)threadAttributes;
- (void)setThreadAttributes:(CMRThreadAttributes *)attributes;
- (BOOL)isAAThread;
- (void)setIsAAThread:(BOOL)flag;
- (BOOL)isDatOchiThread;
- (void)setIsDatOchiThread:(BOOL)flag;
- (BOOL)isMarkedThread;
- (void)setIsMarkedThread:(BOOL)flag;
- (NSArray *)cachedKeywords;
- (void)setCachedKeywords:(NSArray *)array;
- (BSRelativeKeywordsCollector *) keywordsCollector;
/**
  *
  * スレッドが切り替わるとき、
  * サブクラス側に提供されるフック
  * これが呼ばれるときは新しいCMRThreadAttributes
  * はすでにインスタンス変数で保持されている
  *
  */
// Deprecated... Use NSDocument's -setDocument hook future, I wonder...
//- (void) replace : (CMRThreadAttributes *) oldAttrs
//			with : (CMRThreadAttributes *) newAttrs;

- (NSTextStorage *)textStorage;
- (void)setTextStorage:(NSTextStorage *)aTextStorage;

// Deprecated...
//- (BOOL) windowAlreadyExistsForPath : (NSString *) filePath;

// IBActions
// Available in Starlight Breaker.
- (IBAction)showDocumentInfo:(id)sender;
- (IBAction)showMainBrowser:(id)sender;
- (IBAction)toggleAAThread:(id)sender;
- (IBAction)toggleDatOchiThread:(id)sender;
- (IBAction)toggleMarkedThread:(id)sender;
- (IBAction)toggleAAThreadFromInfoPanel:(id)sender;
- (IBAction)revealInFinder:(id)sender; // Available in Twincam Angel and later.
- (IBAction)openInBrowser:(id)sender; // Available in SilverGull and later.
@end

/* for AppleScript */
@interface CMRAbstructThreadDocument(ScriptingSupport)
- (NSTextStorage *)selectedText;

- (NSDictionary *)threadAttrDict;
- (NSString *)threadTitleAsString;
- (NSString *)threadURLAsString;
- (NSString *)boardNameAsString;
- (NSString *)boardURLAsString;

- (void)handleReloadThreadCommand:(NSScriptCommand*)command;
@end


@interface NSWindowController(CMRAbstructThreadDocumentDelegate)
- (void)    document : (NSDocument         *) aDocument
willRemoveController : (NSWindowController *) aController;
@end

extern NSString *const CMRAbstractThreadDocumentDidToggleDatOchiNotification;