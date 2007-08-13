//
//  ConcreteBoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/06.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BoardListItem.h"

@interface ConcreteBoardListItem : BoardListItem
{

}
+ (id) sharedInstance;
@end

@interface ConcreteBoardListItem (Creation)
+ (id) favoritesItem;
@end
