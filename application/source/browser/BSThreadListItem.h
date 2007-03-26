//
//  BSThreadListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/03/18.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <SQLiteDB.h>

@interface BSThreadListItem : NSObject
{
	id data;
}

+ (id)threadItemWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName;
+ (id)threadItemWithIdentifier:(NSString *)identifier boardID:(unsigned)boardID;
+ (id)threadItemWithFilePath:(NSString *)path;
- (id)initWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName;
- (id)initWithIdentifier:(NSString *)identifier boardID:(unsigned)boardID;
- (id)initWithFilePath:(NSString *)path;

+ (NSArray *)threadItemArrayFromCursor:(id <SQLiteCursor>)cursor;

- (NSString *)identifier;
- (NSString *)threadName;
- (unsigned)boardID;
- (NSString *)boardName;
- (NSString *)threadFilePath;
- (ThreadStatus)status;
- (NSNumber *)responseNumber;
- (NSNumber *)readNumber;
- (NSNumber *)delta;
- (NSDate *)creationDate;
- (NSDate *)modifiredDate;
- (NSDate *)lastWrittenDate;

- (NSNumber *)threadNumber;
- (NSImage *)statusImage;

- (NSDictionary *)attribute;

@end

// this class response setValue:forKey: method.
@interface BSMutableThreadListItem : BSThreadListItem
@end


unsigned indexOfIdentifier(NSArray *array, NSString *identifier);

