//
//  DatabaseUpdater.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/02/03.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DatabaseManager.h"

@interface DatabaseUpdater : NSObject
{
}

+ (Class)updaterFrom:(int)from to:(int)to;

@end

@interface DatabaseUpdater(UpdateMethod)
- (BOOL) updateDB;
@end