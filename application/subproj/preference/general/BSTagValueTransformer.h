//
//  BSTagValueTransformer.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/03.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// これらの NSValueTransformer subClasses にはあまり汎用性がない。

//「一般」ペインで使用する
@interface BSTagValueTransformer : NSValueTransformer {

}

@end
//「フィルタ」ペインで使用する
@interface BSTagToBoolTransformer : NSValueTransformer {

}

@end
