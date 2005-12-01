// BoardManager-BSAddition.m
#import "BoardManager_p.h"
#import "NoNameInputController.h"


/* constants */
// NND means 'NoNameDict'.
static NSString *const NNDNoNameKey			= @"NoName";
static NSString *const NNDSortColumnKey		= @"SortColumn";
static NSString *const NNDIsAscendingKey	= @"IsAscending";
static NSString *const NNDAlwaysBeLoginKey	= @"AlwaysBeLogin";
static NSString *const NNDDefaultKotehanKey = @"DefaultReplyName";
static NSString *const NNDDefaultMailKey	= @"DefaultReplyMail";
static NSString *const NNDAllThreadsAAKey	= @"AABoard";

extern NSImage  *imageForType(BoardListItemType type); // described in BoardList-OVDatasource.m

@implementation BoardManager(BSAddition)

- (NSDictionary *) noNameDict
{
	if (nil == _noNameDict) {
		_noNameDict = [[NSDictionary alloc] initWithContentsOfFile : 
										[[self class] NNDFilepath]];
	}
	if (nil == _noNameDict) {
		_noNameDict = [[NSDictionary empty] copy];
	}
	
	return _noNameDict;
}
- (void) setNoNameDict : (NSDictionary *) aNoNameDict
{
	id		tmp;
	
	tmp = _noNameDict;
	_noNameDict = [aNoNameDict copyWithZone : [self zone]];
	[tmp release];
}

#pragma mark (Since CMRNoNameManager)

- (id) entryForBoardName : (NSString *) aBoardName
{
	return [[self noNameDict] objectForKey : aBoardName];
}

/* 名無しさんの名前 */
- (NSString *) defaultNoNameForBoard : (NSString *) boardName
{
	id entry_;
	
	entry_ = [self entryForBoardName : boardName];

	if ([entry_ isKindOfClass : [NSString class]]) {
		return [[self noNameDict] stringForKey : boardName];
	} else if ([entry_ isKindOfClass : [NSDictionary class]]) {
		return [entry_ stringForKey : NNDNoNameKey];
	} else {
		return nil;
	}
}
- (void) setDefaultNoName : (NSString *) aName
			 	 forBoard : (NSString *) boardName
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(aName);
	UTILAssertNotNil(boardName);
	
	entry_ = [self entryForBoardName : boardName];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		[mdict_ setObject : [NSDictionary dictionaryWithObject : aName forKey : NNDNoNameKey]
				   forKey : boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject : aName forKey : NNDNoNameKey];
		
		[mdict_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

- (NSString *) sortColumnForBoard : (NSString *) boardName
{
	id entry_;
	NSString	*str_;
	
	entry_ = [self entryForBoardName : boardName];

	if ([entry_ isKindOfClass : [NSDictionary class]]) {
		str_ = [entry_ stringForKey : NNDSortColumnKey];
	} else {
		str_ = nil;
	}
	
	if (str_ == nil) str_ = [CMRPref browserSortColumnIdentifier];
	return str_;
}

- (void) setSortColumn : (NSString *) anIdentifier
			  forBoard : (NSString *) boardName
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(anIdentifier);
	UTILAssertNotNil(boardName);
	
	entry_ = [self entryForBoardName : boardName];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, anIdentifier, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDSortColumnKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : anIdentifier, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDSortColumnKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject : anIdentifier forKey : NNDSortColumnKey];
		
		[mdict_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}


- (BOOL) sortColumnIsAscendingAtBoard : (NSString *) boardName
{
	id entry_;
	
	entry_ = [self entryForBoardName : boardName];

	if ([entry_ isKindOfClass : [NSString class]]) {
		return [CMRPref browserSortAscending];
	} else if ([entry_ isKindOfClass : [NSDictionary class]]) {
		if ([[entry_ allKeys] containsObject : NNDIsAscendingKey]) {
			return [entry_ boolForKey : NNDIsAscendingKey];
		} else {
			return [CMRPref browserSortAscending];
		}
	} else {
		return [CMRPref browserSortAscending];
	}
}

- (void) setSortColumnIsAscending : (BOOL	   ) isAscending
						  atBoard : (NSString *) boardName;
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(boardName);
	
	entry_ = [self entryForBoardName : boardName];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, [NSNumber numberWithBool : isAscending], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDIsAscendingKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : [NSNumber numberWithBool : isAscending], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDIsAscendingKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setBool : isAscending forKey : NNDIsAscendingKey];
		
		[mdict_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

#pragma mark (SledgeHammer Addition)
- (BOOL) alwaysBeLoginAtBoard : (NSString *) boardName
{
	BSBeLoginPolicyType	policy_;
	
	policy_ = [self typeOfBeLoginPolicyForBoard : boardName];
	
	if ((policy_ == BSBeLoginTriviallyOFF) || (policy_ == BSBeLoginNoAccountOFF)) {
		return NO;
	
	} else if (policy_ == BSBeLoginTriviallyNeeded) {
		return YES;

	} else {
		id entry_;
		entry_ = [self entryForBoardName : boardName];

		if ([entry_ isKindOfClass : [NSString class]]) {
			return [CMRPref shouldLoginBe2chAnyTime];
		} else if ([entry_ isKindOfClass : [NSDictionary class]]) {
			if ([[entry_ allKeys] containsObject : NNDAlwaysBeLoginKey]) {
				return [entry_ boolForKey : NNDAlwaysBeLoginKey];
			} else {
				return [CMRPref shouldLoginBe2chAnyTime];
			}
		} else {
			return [CMRPref shouldLoginBe2chAnyTime];
		}
	}
}

- (void) setAlwaysBeLogin : (BOOL	   ) alwaysLogin
				  atBoard : (NSString *) boardName
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(boardName);
	
	entry_ = [self entryForBoardName : boardName];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, [NSNumber numberWithBool : alwaysLogin], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDAlwaysBeLoginKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : [NSNumber numberWithBool : alwaysLogin], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDAlwaysBeLoginKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setBool : alwaysLogin forKey : NNDAlwaysBeLoginKey];
		
		[mdict_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

- (NSString *) defaultKotehanForBoard : (NSString *) boardName
{
	id entry_;
	NSString	*str_;
	
	entry_ = [self entryForBoardName : boardName];

	if ([entry_ isKindOfClass : [NSDictionary class]]) {
		str_ = [entry_ stringForKey : NNDDefaultKotehanKey];
	} else {
		str_ = nil;
	}
	
	if (str_ == nil) str_ = [CMRPref defaultReplyName];
	return str_;
}

- (void) setDefaultKotehan : (NSString *) aName
				  forBoard : (NSString *) boardName
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(aName);
	UTILAssertNotNil(boardName);
	
	entry_ = [self entryForBoardName : boardName];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, aName, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDDefaultKotehanKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : aName, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDDefaultKotehanKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject : aName forKey : NNDDefaultKotehanKey];
		
		[mdict_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

- (NSString *) defaultMailForBoard : (NSString *) boardName
{
	id entry_;
	NSString	*str_;
	
	entry_ = [self entryForBoardName : boardName];

	if ([entry_ isKindOfClass : [NSDictionary class]]) {
		str_ = [entry_ stringForKey : NNDDefaultMailKey];
	} else {
		str_ = nil;
	}
	
	if (str_ == nil) str_ = [CMRPref defaultReplyMailAddress];
	return str_;
}

- (void) setDefaultMail : (NSString *) aString
			   forBoard : (NSString *) boardName
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(aString);
	UTILAssertNotNil(boardName);
	
	entry_ = [self entryForBoardName : boardName];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, aString, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDDefaultMailKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : aString, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDDefaultMailKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject : aString forKey : NNDDefaultMailKey];
		
		[mdict_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

#pragma mark (LittleWish Addition)
// LittleWish Addition
- (BOOL) allThreadsShouldAAThreadAtBoard : (NSString *) boardName
{
	id entry_;
	
	entry_ = [self entryForBoardName : boardName];

	if ([entry_ isKindOfClass : [NSString class]]) {
		return NO;
	} else if ([entry_ isKindOfClass : [NSDictionary class]]) {
		if ([[entry_ allKeys] containsObject : NNDAllThreadsAAKey]) {
			return [entry_ boolForKey : NNDAllThreadsAAKey];
		} else {
			return NO;
		}
	} else {
		return NO;
	}
}

- (void) setAllThreadsShouldAAThread : (BOOL      ) shouldAAThread
							 atBoard : (NSString *) boardName
{
	NSMutableDictionary		*mdict_;
	id entry_;
	
	UTILAssertNotNil(boardName);
	
	entry_ = [self entryForBoardName : boardName];
	
	mdict_ = [[self noNameDict] mutableCopyWithZone : [self zone]];
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, [NSNumber numberWithBool : shouldAAThread], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDAllThreadsAAKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : [NSNumber numberWithBool : shouldAAThread], nil];
			tempKeys	= [NSArray arrayWithObjects : NNDAllThreadsAAKey, nil];
		}
		[mdict_ setObject : [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				   forKey : boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setBool : shouldAAThread forKey : NNDAllThreadsAAKey];
		
		[mdict_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
	[self setNoNameDict : mdict_];
	[mdict_ release];
}

- (NSImage *) iconForBoard : (NSString *) boardName
{
	// Future will be...
	/*BoardListItem	*item_;
	item_ = [self itemForName : boardName];
	
	return [item_ icon];*/
	if ([boardName isEqualToString : CMXFavoritesDirectoryName]) {
		return imageForType(BoardListFavoritesItem);
	} else {
		return imageForType(BoardListBoardItem);
	}
}

- (BSBeLoginPolicyType) typeOfBeLoginPolicyForBoard : (NSString *) boardName
{
	if(![CMRPref availableBe2chAccount])
		return BSBeLoginNoAccountOFF;

	const char *hs;
	
	hs = [[[self URLForBoardName : boardName] host] UTF8String];
	
	if (NULL == hs)
		return BSBeLoginDecidedByUser;

	if (!is_2channel(hs)) return BSBeLoginTriviallyOFF;	
	if (is_2ch_belogin_needed(hs)) return BSBeLoginTriviallyNeeded;
	
	return BSBeLoginDecidedByUser;
}	

#pragma mark -

- (NSString *) askUserAboutDefaultNoNameForBoard : (NSString *) boardName
									 presetValue : (NSString *) aValue
{
	NoNameInputController	*controller_;
	NSString				*v;
	
	controller_ = [[NoNameInputController alloc] init];
	v = [controller_ askUserAboutDefaultNoNameForBoard : boardName presetValue : aValue];
	
	if (v != nil) {
		[self setDefaultNoName : v forBoard : boardName];
	}
	[controller_ release];
	
	return v;
}
@end