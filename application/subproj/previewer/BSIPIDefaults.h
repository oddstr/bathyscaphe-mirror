//
//  BSIPIDefaults.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/08/31.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@class AppDefaults;

@interface BSIPIDefaults : NSObject {
	@private
	AppDefaults	*m_defaults;
}

+ (id)sharedIPIDefaults;

- (AppDefaults *)appDefaults;
- (void)setAppDefaults:(AppDefaults *)appDefaults;

- (BOOL)alwaysBecomeKey;
- (void)setAlwaysBecomeKey:(BOOL)alwaysKey;

- (NSString *)saveDirectory;
- (void)setSaveDirectory:(NSString *)aString;

- (float)alphaValue;
- (void)setAlphaValue:(float)newValue;

- (BOOL)opaqueWhenKey;
- (void)setOpaqueWhenKey:(BOOL)opaqueWhenKey;

- (BOOL)resetWhenHide;
- (void)setResetWhenHide:(BOOL)reset;

- (BOOL)floating;
- (void)setFloating:(BOOL)floatOrNot;

- (int)preferredView;
- (void)setPreferredView:(int)aType;

- (int)lastShownViewTag;
- (void)setLastShownViewTag:(int)aTag;

- (BOOL)leaveFailedToken;
- (void)setLeaveFailedToken:(BOOL)leave;

- (float)fullScreenWheelAmount;
- (void)setFullScreenWheelAmount:(float)floatValue;

- (BOOL)useIKSlideShowOnLeopard;
- (void)setUseIKSlideShowOnLeopard:(BOOL)flag;

- (NSData *)fullScreenBgColorData;
- (void)setFullScreenBgColorData:(NSData *)aColorData;

- (BOOL)attachFinderComment;
- (void)setAttachFinderComment:(BOOL)flag;
@end

// For KVO
extern void *kBSIPIDefaultsContext;
