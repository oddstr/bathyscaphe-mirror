// encoding="UTF-8"

#import "NSIndexSet+BSAddition.h"

@implementation NSIndexSet(BSAddition)
+ (NSIndexSet *) rowIndexesWithRows: (NSArray *) rows
{
    if (!rows || [rows count] == 0) return nil;
    
    NSMutableIndexSet   *indexSet = [NSMutableIndexSet indexSet];
    NSEnumerator        *iter_ = [rows objectEnumerator];
    id                  eachItem_;
    
    while (eachItem_ = [iter_ nextObject]) {
        [indexSet addIndex: [eachItem_ unsignedIntValue]];
    }
    
    return indexSet;
}
@end
