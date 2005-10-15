//
//  BSImagePreviewerInterface.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/10/15.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

@class AppDefaults;

@protocol BSImagePreviewerProtocol
// Designated Initializer
- (id) initWithPreferences : (AppDefaults *) prefs;
// Accessor
- (AppDefaults *) preferences;
- (void) setPreferences : (AppDefaults *) aPreferences;
// Action
- (BOOL) showImageWithURL : (NSURL *) imageURL;
- (BOOL) validateLink : (NSURL *) anURL;
@end

@interface NSObject(IPPAdditions)
// Storage for plugin-specific settings
- (NSMutableDictionary *) imagePreviewerPrefsDict;

//  Accessor for useful BathyScaphe global settings
- (BOOL) openInBg;
- (BOOL) isOnlineMode;
@end