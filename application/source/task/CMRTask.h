//
//  CMRTask.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
#import <AppKit/NSNibDeclarations.h>


@protocol CMRTask<NSObject>
/*!
 * @method      identifier
 * @abstract    識別子
 * @discussion  
 *
 * CMRTaskManager が個々を識別するための一意なオブジェクト
 * nil を返すと CMRTaskManager に登録されない。
 * 通常は文字列を返す。
 *
 * @result      識別子となるオブジェクト
 */
- (id)identifier;

// BathyScaphe では Cocoa Binding や KVO を多用するので、-setTitle:/-setMessage:/-setIsInProgress:/-setAmount: の実装も強く推奨。
- (NSString *)title;
- (NSString *)message;
- (BOOL)isInProgress;

// from 0.0 to 100.0 (or -1: Indeterminate)
- (double)amount;
- (IBAction)cancel:(id)sender;
@end


@interface NSObject(CMRTaskInformalProtocol)
- (void)setTitle:(NSString *)title;
- (void)setMessage:(NSString *)msg;
- (void)setIsInProgress:(BOOL)isInProgress;
- (void)setAmount:(double)doubleValue;
@end

// Notification Name.
extern NSString *const CMRTaskWillStartNotification;
extern NSString *const CMRTaskDidFinishNotification;
