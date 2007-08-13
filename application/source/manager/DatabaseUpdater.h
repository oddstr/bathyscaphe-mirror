//
//  DatabaseUpdater.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/02/03.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DatabaseManager.h"

@interface DatabaseUpdater : NSObject
{
}

+ (BOOL)updateFrom:(int)fromVersion to:(int)toVersion;

@end

@interface DatabaseUpdater(UpdateMethod)
- (BOOL) updateDB;
@end