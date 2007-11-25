//
//  BSPreferencesPaneInterface.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/25.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

@class AppDefaults;

@protocol BSPreferencesPaneProtocol
- (id)initWithPreferences:(AppDefaults *)prefs;

- (NSString *)currentIdentifier;
- (void)setCurrentIdentifier:(NSString *)identifier;

- (void)showPreferencesPaneWithIdentifier:(NSString *)identifier;
@end

// Pane identifier constants.
#define PPGeneralPreferencesIdentifier	@"General"
#define PPFontsAndColorsIdentifier		@"FontsAndColors"
#define PPAccountSettingsIdentifier		@"AccountSettings"
#define PPFilterPreferencesIdentifier	@"Filter"
#define PPReplyDefaultIdentifier		@"RepltDefaults"
#define PPAdvancedPreferencesIdentifier	@"Advanced"
#define PPSoundsPreferencesIdentifier	@"Sounds"	// Available in BathyScaphe 1.2 and later.
#define PPSyncPreferencesIdentifier		@"Sync"		// Available in BathyScaphe 1.3 and later.
#define PPLinkPreferencesIdentifier		@"Link"		// Available in BathyScaphe 1.6 and later.
