//
//  BSSearchOptions.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/17.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoMonar/CocoMonar.h>

@interface BSSearchOptions : NSObject<NSCopying> {//, CMRPropertyListCoding> {
	@private
	NSString		*m_searchString;
	NSArray			*m_targetKeysArray;
	CMRSearchMask	m_searchMask;
}

+ (id) operationWithFindObject: (NSString *) searchString
					   options: (CMRSearchMask) options
						target: (NSArray *) keysArray;
- (id) initWithFindObject: (NSString *) searchString
				  options: (CMRSearchMask) options
				   target: (NSArray *) keysArray;

- (NSString *) findObject;
- (NSArray *) targetKeysArray;
- (CMRSearchMask) optionMasks;

- (BOOL) optionStateForOption: (CMRSearchMask) opt;
- (void) setOptionState: (BOOL) flag
			  forOption: (CMRSearchMask) opt;
@end
