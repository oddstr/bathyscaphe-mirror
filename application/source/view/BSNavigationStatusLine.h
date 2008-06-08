//
//  BSNavigationStatusLine.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/05/04.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRStatusLine.h"

@class CMRIndexingStepper, BSIndexingPopupper;

@interface BSNavigationStatusLine : CMRStatusLine {
	CMRIndexingStepper			*m_indexingStepper;
	BSIndexingPopupper			*m_indexingPopupper;
}

- (CMRIndexingStepper *)indexingStepper;
- (BSIndexingPopupper *)indexingPopupper;
@end
