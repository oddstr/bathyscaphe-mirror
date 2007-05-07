// BoardManager-BSAddition.m
#import "BoardManager_p.h"
#import "NoNameInputController.h"

#import "DatabaseManager.h"

/* constants */
// NND means 'NoNameDict'.
static NSString *const NNDNoNameKey			= @"NoName";
static NSString *const NNDSortColumnKey		= @"SortColumn";
static NSString *const NNDIsAscendingKey	= @"IsAscending";
static NSString *const NNDSortDescriptors	= @"SortDescriptors";
static NSString *const NNDAlwaysBeLoginKey	= @"AlwaysBeLogin";
static NSString *const NNDDefaultKotehanKey = @"DefaultReplyName";
static NSString *const NNDDefaultMailKey	= @"DefaultReplyMail";
static NSString *const NNDAllThreadsAAKey	= @"AABoard";
static NSString *const NNDBeLoginPolicyTypeKey = @"BeLoginPolicy";
static NSString *const NNDAllowsNanashiKey	= @"AllowsNanashi";

extern NSImage  *imageForType(BoardListItemType type); // described in BoardList-OVDatasource.m

@implementation BoardManager(BSAddition)

- (NSMutableDictionary *) noNameDict
{
	if (nil == _noNameDict) {
		NSString *errorStr;
		NSMutableData	*plistData;
		
		plistData = [NSMutableData dataWithContentsOfFile: [[self class] NNDFilepath]];
		if (plistData) {
			_noNameDict = [NSPropertyListSerialization propertyListFromData: plistData
														   mutabilityOption: NSPropertyListMutableContainersAndLeaves
																	 format: NULL
														   errorDescription: &errorStr];
			if (!_noNameDict) {
				NSLog(@"BoardManager failed to read BoardProperties.plist using NSPropertyListSerialization.");
				//NSLog(errorStr);
				//[errorStr release];
			} else {
				[_noNameDict retain];
			}
		}
	}

	if (nil == _noNameDict) {
		_noNameDict = [[NSMutableDictionary alloc] initWithContentsOfFile: [[self class] NNDFilepath]];
	}
	if (nil == _noNameDict) {
		_noNameDict = [[NSMutableDictionary alloc] initWithContentsOfFile: [[self class] oldNNDFilepath]];
	}
	if (nil == _noNameDict) {
		_noNameDict = [[NSMutableDictionary alloc] init];
	}
	
	return _noNameDict;
}
- (void) setNoNameDict : (NSMutableDictionary *) aNoNameDict
{
	@synchronized(self) {
		[aNoNameDict retain];
		[_noNameDict release];
		_noNameDict = aNoNameDict;
	}
}

- (id) entryForBoardName : (NSString *) aBoardName
{
	return [[self noNameDict] objectForKey : aBoardName];
}

- (id) valueForBoard: (NSString *) boardName
				 key: (NSString *) key
		defaultValue: (id) value
{
	id entry_ = [self entryForBoardName: boardName];
	id value_ = nil;
	
	if ([entry_ isKindOfClass: [NSDictionary class]]) {
		value_ = [entry_ valueForKey: key];
	}
	
	if (value_ == nil) value_ = value;
	return value_;
}
- (void) setValue: (id) value forKey: (NSString *) key atBoard: (NSString *) boardName
{
	UTILAssertNotNil(value);
	UTILAssertNotNil(boardName);
	
	// can serialize using NSPropertyListSerialization.
	{
		id obj;
		obj = [NSPropertyListSerialization dataFromPropertyList: value
														 format: NSPropertyListBinaryFormat_v1_0
											   errorDescription: nil];
		if(!obj) {
			NSLog(@"It is not permitted though you try to put object which can not serialize using NSPropertyListSerialization into NoNameDict.");
			return;
		}
	}
	
	NSMutableDictionary		*nnd_ = [self noNameDict];
	id entry_ = [self entryForBoardName : boardName];
	
	if (entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, value, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, key, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : value, nil];
			tempKeys	= [NSArray arrayWithObjects : key, nil];
		}
		[nnd_ setObject: [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				 forKey: boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject: value forKey: key];
		[nnd_ setObject: mutableEntry_ forKey: boardName];
		[mutableEntry_ release];
	}
}

- (NSString *) stringValueForBoard: (NSString *) boardName
                               key: (NSString *) key
                      defaultValue: (NSString *) value
{
    id entry_ = [self entryForBoardName: boardName];
    NSString    *str_ = nil;
    
    if ([entry_ isKindOfClass: [NSDictionary class]]) {
        str_ = [entry_ stringForKey: key];
    }
    
    if (str_ == nil) str_ = value;
    return str_;
}

- (void) setStringValue: (NSString *) value withKey: (NSString *) key forBoard: (NSString *) boardName
{
	UTILAssertNotNil(value);
	UTILAssertNotNil(boardName);
	
	NSMutableDictionary		*nnd_ = [self noNameDict];
	id entry_ = [self entryForBoardName : boardName];
	
	if (entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, value, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, key, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : value, nil];
			tempKeys	= [NSArray arrayWithObjects : key, nil];
		}
		[nnd_ setObject: [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				 forKey: boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setObject: value forKey: key];
		[nnd_ setObject: mutableEntry_ forKey: boardName];
		[mutableEntry_ release];
	}
}

- (BOOL) boolValueForBoard: (NSString *) boardName
                       key: (NSString *) key
              defaultValue: (BOOL) value
{
	id entry_ = [self entryForBoardName : boardName];
	
	if ([entry_ isKindOfClass: [NSDictionary class]] && [[entry_ allKeys] containsObject: key]) {
	   return [entry_ boolForKey: key];
	}
	
	return value;
}

- (void) setBoolValue: (BOOL) value forKey: (NSString *) key atBoard: (NSString *) boardName
{
	UTILAssertNotNil(boardName);
	
	NSMutableDictionary		*nnd_ = [self noNameDict];
	id entry_ = [self entryForBoardName : boardName];
	
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		NSNumber  *value_ = [NSNumber numberWithBool: value];
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, value_, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, key, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : value_, nil];
			tempKeys	= [NSArray arrayWithObjects : key, nil];
		}
		[nnd_ setObject: [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				 forKey: boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setBool: value forKey: key];
		[nnd_ setObject: mutableEntry_ forKey: boardName];
		[mutableEntry_ release];
	}
}

#pragma mark (Since CMRNoNameManager)
- (NSString *) sortColumnForBoard : (NSString *) boardName
{
	return [self stringValueForBoard: boardName
	                             key: NNDSortColumnKey
	                    defaultValue: [CMRPref browserSortColumnIdentifier]];
}

- (void) setSortColumn : (NSString *) anIdentifier
			  forBoard : (NSString *) boardName
{
    [self setStringValue: anIdentifier withKey: NNDSortColumnKey forBoard: boardName];
}

- (BOOL) sortColumnIsAscendingAtBoard : (NSString *) boardName
{
	return [self boolValueForBoard: boardName
	                           key: NNDIsAscendingKey
	                  defaultValue: [CMRPref browserSortAscending]];
}

- (void) setSortColumnIsAscending : (BOOL	   ) isAscending
						  atBoard : (NSString *) boardName;
{
    [self setBoolValue: isAscending forKey: NNDIsAscendingKey atBoard: boardName];
}

// 1.4 or 1.5 addition
// NSSortDescriptor は NSDictionary に分解されて保存されている。
static inline NSDictionary *dctionaryFromSortDescriptor(NSSortDescriptor *sortDescriptor)
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:[sortDescriptor ascending]], NNDIsAscendingKey,
		[sortDescriptor key], NNDSortColumnKey,
		nil];
}
static NSArray *plistArrayFromSortDescriptors(NSArray *sortDescriptors)
{
	NSMutableArray *result;
	id enume, obj;
	
	result = [NSMutableArray arrayWithCapacity:[sortDescriptors count]];
	enume = [sortDescriptors objectEnumerator];
	while(obj = [enume nextObject]) {
		[result addObject:dctionaryFromSortDescriptor(obj)];
	}
	
	return result;
}
static NSArray *sortDescriptorsFromPlistArray(NSArray *plist)
{
	NSMutableArray *result;
	id enume, obj;
	
	result = [NSMutableArray arrayWithCapacity:[plist count]];
	enume = [plist objectEnumerator];
	while(obj = [enume nextObject]) {
		NSSortDescriptor *sortDescriptor;
		
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[obj valueForKey:NNDSortColumnKey]
													 ascending:[[obj valueForKey:NNDIsAscendingKey] boolValue]
													  selector:@selector(numericCompare:)];
		[result addObject:sortDescriptor];
		[sortDescriptor release];
	}
	
	return result;
}
- (NSArray *) sortDescriptorsForBoard : (NSString *) boardName
{
	NSArray *array;
	NSSortDescriptor *sortDescriptor;
	
	array = [self valueForBoard: boardName
							key: NNDSortDescriptors
				   defaultValue: nil];
	
	// ここでデフォルトを生成。
	if(!array) {
		NSMutableArray *result = [NSMutableArray array];
//		id key = [CMRPref browserSortColumnIdentifier];
//		BOOL asc = [CMRPref browserSortAscending];
		id key = [self sortColumnForBoard:boardName]; // 古い設定からのコンバートも考慮
		BOOL asc = [self sortColumnIsAscendingAtBoard:boardName];
		
		sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:tableNameForKey(key)
													  ascending:asc
													   selector:@selector(numericCompare:)] autorelease];
		[result addObject:sortDescriptor];
		
		// index でソートしないと変なので。
		if(![key isEqualTo:CMRThreadSubjectIndexKey]) {
			sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:tableNameForKey(CMRThreadSubjectIndexKey)
														  ascending:YES
														   selector:@selector(numericCompare:)] autorelease];
			[result addObject:sortDescriptor];
		}
		
		return result;
	}
	
	return sortDescriptorsFromPlistArray(array);
}

- (void) setSortDescriptors : (NSArray *) sortDescriptors
				   forBoard : (NSString *) boardName
{
	[self setValue: plistArrayFromSortDescriptors(sortDescriptors)
			forKey: NNDSortDescriptors
		   atBoard: boardName];
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
        id entry_ = [self entryForBoardName : boardName];

        if ([entry_ isKindOfClass: [NSDictionary class]] && [[entry_ allKeys] containsObject: NNDAlwaysBeLoginKey]) {
	       return [entry_ boolForKey: NNDAlwaysBeLoginKey];
        }

        return [CMRPref shouldLoginBe2chAnyTime];
	}
}

- (void) setAlwaysBeLogin : (BOOL	   ) alwaysLogin
				  atBoard : (NSString *) boardName
{
    [self setBoolValue: alwaysLogin forKey: NNDAlwaysBeLoginKey atBoard: boardName];
}

- (NSString *) defaultKotehanForBoard : (NSString *) boardName
{
	return [self stringValueForBoard: boardName
	                             key: NNDDefaultKotehanKey
	                    defaultValue: [CMRPref defaultReplyName]];
}

- (void) setDefaultKotehan : (NSString *) aName
				  forBoard : (NSString *) boardName
{
    [self setStringValue: aName withKey: NNDDefaultKotehanKey forBoard: boardName];
}

- (NSString *) defaultMailForBoard : (NSString *) boardName
{
	return [self stringValueForBoard: boardName
	                             key: NNDDefaultMailKey
	                    defaultValue: [CMRPref defaultReplyMailAddress]];
}

- (void) setDefaultMail : (NSString *) aString
			   forBoard : (NSString *) boardName
{
    [self setStringValue: aString withKey: NNDDefaultMailKey forBoard: boardName];
}

#pragma mark (LittleWish Addition)
// LittleWish Addition
- (BOOL) allThreadsShouldAAThreadAtBoard : (NSString *) boardName
{
	return [self boolValueForBoard: boardName
	                           key: NNDAllThreadsAAKey
	                  defaultValue: NO];
}

- (void) setAllThreadsShouldAAThread : (BOOL      ) shouldAAThread
							 atBoard : (NSString *) boardName
{
    [self setBoolValue: shouldAAThread forKey: NNDAllThreadsAAKey atBoard: boardName];
}

- (id)itemForName : (NSString *) boardName
{
	id list_;
	id item_;
	
	list_ = [self userList];
	item_ = [list_ itemForName : boardName];
	if(item_) return item_;
	
	list_ = [self defaultList];
	item_ = [list_ itemForName : boardName];
	
	return item_;
}
- (NSImage *) iconForBoard : (NSString *) boardName
{
	// Future will be...
	BoardListItem	*item_;
	item_ = [self itemForName : boardName];
	
	return [item_ icon];
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
	//if (is_2ch_belogin_needed(hs)) return BSBeLoginTriviallyNeeded;
	{
		id entry_;
		
		entry_ = [self entryForBoardName : boardName];

		if ([entry_ isKindOfClass : [NSDictionary class]]) {
			if ([[entry_ allKeys] containsObject : NNDBeLoginPolicyTypeKey]) {
				return [entry_ unsignedIntForKey : NNDBeLoginPolicyTypeKey];
			}
		}
	}

	return BSBeLoginDecidedByUser;
}

#pragma mark (MeteorSweeper Addition)
- (NSSet *) defaultNoNameSetForBoard: (NSString *) boardName
{
	id entry_;
	
	entry_ = [self entryForBoardName: boardName];
	
	if ([entry_ isKindOfClass: [NSDictionary class]]) {
		id	object_ = [entry_ objectForKey: NNDNoNameKey];
		if ([object_ isKindOfClass: [NSString class]]) {
			return [NSSet setWithObject: object_];
		} else if ([object_ isKindOfClass: [NSArray class]]) {
			return [NSSet setWithArray: object_];
		}
	} else if ([entry_ isKindOfClass: [NSString class]]) {
		return [NSSet setWithObject: [[self noNameDict] stringForKey: boardName]];
	}

	return nil;
}

- (void) setDefaultNoNameSet: (NSSet *) newSet forBoard: (NSString *) boardName
{
	UTILAssertNotNil(newSet);
	UTILAssertNotNil(boardName);

	BOOL	shouldRemove = ([newSet count] == 0) ? YES : NO;

    NSMutableDictionary *nnd_ = [self noNameDict]; 	
	id entry_ = [self entryForBoardName : boardName];
	
	if (entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		if (shouldRemove) {
			[nnd_ removeObjectForKey: boardName];
		} else {
			[nnd_ setObject: [NSDictionary dictionaryWithObject: [newSet allObjects] forKey: NNDNoNameKey]
					 forKey: boardName];
		}
	} else {
		NSMutableDictionary		*mutableEntry_;
		
		mutableEntry_ = [entry_ mutableCopy];
		
		if (shouldRemove) {
			[mutableEntry_ removeObjectForKey: NNDNoNameKey];
		} else {
			[mutableEntry_ setObject : [newSet allObjects] forKey : NNDNoNameKey];
		}
		[nnd_ setObject: mutableEntry_ forKey: boardName];
		[mutableEntry_ release];
	}
}

- (void) addNoName: (NSString *) additionalNoName forBoard: (NSString *) boardName
{
	UTILAssertNotNil(additionalNoName);
	UTILAssertNotNil(boardName);

	NSMutableSet *tmpSet_;
	NSSet *tmpSetBase_ = [self defaultNoNameSetForBoard: boardName];

	if(!tmpSetBase_) {
		tmpSet_ = [[NSMutableSet alloc] initWithCapacity: 1];
	} else {
		tmpSet_ = [tmpSetBase_ mutableCopy];
	}
	
	[tmpSet_ addObject: additionalNoName];
	[self setDefaultNoNameSet: tmpSet_ forBoard: boardName];
	[tmpSet_ release];
}

- (void) removeNoName: (NSString *) removingNoName forBoard: (NSString *) boardName
{
	UTILAssertNotNil(removingNoName);
	UTILAssertNotNil(boardName);

	NSSet *tmpSetBase_ = [self defaultNoNameSetForBoard: boardName];

	if (!tmpSetBase_) {
		return;
	}
	
	if (![tmpSetBase_ containsObject: removingNoName]) {
		return;
	}

	NSMutableSet *tmpSet_ = [tmpSetBase_ mutableCopy];
	
	[tmpSet_ removeObject: removingNoName];
	[self setDefaultNoNameSet: tmpSet_ forBoard: boardName];
	[tmpSet_ release];
}

- (void) exchangeNoName: (NSString *) oldName toNewValue: (NSString *) newName forBoard: (NSString *) boardName
{
	UTILAssertNotNil(oldName);
	UTILAssertNotNil(newName);
	UTILAssertNotNil(boardName);

	NSSet *tmpSetBase_ = [self defaultNoNameSetForBoard: boardName];

	if (!tmpSetBase_) {
		return;
	}
	
	if (![tmpSetBase_ containsObject: oldName]) {
		return;
	}

	NSMutableSet *tmpSet_ = [tmpSetBase_ mutableCopy];
	
	[tmpSet_ removeObject: oldName];
	[tmpSet_ addObject: newName];
	[self setDefaultNoNameSet: tmpSet_ forBoard: boardName];
	[tmpSet_ release];
}

- (void) setTypeOfBeLoginPolicy: (BSBeLoginPolicyType) aType forBoard: (NSString *) boardName
{
	if (aType == BSBeLoginDecidedByUser) return; // Currently not need to record it
	
	UTILAssertNotNil(boardName);

	NSMutableDictionary		*nnd_ = [self noNameDict];
	id entry_ = [self entryForBoardName : boardName];
	
	if(entry_ == nil || [entry_ isKindOfClass : [NSString class]]) {
		NSArray	*tempObjects, *tempKeys;
		NSNumber  *value_ = [NSNumber numberWithUnsignedInt: aType];
		
		if (entry_ != nil) {
			tempObjects = [NSArray arrayWithObjects : entry_, value_, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDNoNameKey, NNDBeLoginPolicyTypeKey, nil];
		} else {
			tempObjects = [NSArray arrayWithObjects : value_, nil];
			tempKeys	= [NSArray arrayWithObjects : NNDBeLoginPolicyTypeKey, nil];
		}
		[nnd_ setObject: [NSDictionary dictionaryWithObjects : tempObjects forKeys : tempKeys]
				 forKey: boardName];
	} else {
		NSMutableDictionary		*mutableEntry_;
		mutableEntry_ = [entry_ mutableCopy];
		[mutableEntry_ setUnsignedInt : aType forKey : NNDBeLoginPolicyTypeKey];
		[nnd_ setObject : mutableEntry_ forKey : boardName];
		[mutableEntry_ release];
	}
}

#pragma mark ReinforceII Addition
- (BOOL) allowsNanashiAtBoard: (NSString *) boardName
{
	return [self boolValueForBoard: boardName
	                           key: NNDAllowsNanashiKey
	                  defaultValue: YES];
}

- (void) setAllowsNanashi: (BOOL) allows atBoard: (NSString *) boardName
{
    [self setBoolValue: allows forKey: NNDAllowsNanashiKey atBoard: boardName];
}

#pragma mark Starlight Breaker Addition
- (void) passPropertiesOfBoardName: (NSString *) boardName toBoardName: (NSString *) newBoardName
{
	if (!boardName || !newBoardName || [boardName isEqualToString: newBoardName]) return;
	id dict = [[self noNameDict] objectForKey: boardName];
	if (!dict) return;

	[[self noNameDict] setObject: dict forKey: newBoardName];
	[[self noNameDict] removeObjectForKey: boardName];
}


#pragma mark -

- (NSString *) askUserAboutDefaultNoNameForBoard : (NSString *) boardName
									 presetValue : (NSString *) aValue
{
	NoNameInputController	*controller_;
	NSString				*v;
	
	controller_ = [[NoNameInputController alloc] init];
	v = [controller_ askUserAboutDefaultNoNameForBoard : boardName presetValue : aValue];
/*	
	if (v != nil) {
		[self setDefaultNoName : v forBoard : boardName];
	}
*/
	[controller_ release];
	
	return v;
}

- (BOOL) needToDetectNoNameForBoard: (NSString *) boardName
{
//	if ([boardName isEqualToString: BSbbynewsBoardName]) return NO;
	if ([boardName hasSuffix: @"headline"]) return NO;
	NSSet *set_ = [self defaultNoNameSetForBoard: boardName];
	if (!set_ || [set_ count] == 0) return YES;
	
	return NO;
}
@end