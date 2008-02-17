#import "CMRHostHandler.h"
#import "CocoMonar_Prefix.h"

// Described in CMRHostHandler.m
@interface CMR2channelHandler : CMRHostHandler
@end

@interface CMR2channelOtherHandler : CMR2channelHandler
@end

//@interface CMR2channelBeHandler : CMR2channelHandler
//@end

// Described in CMRHostHTMLHandler.m
@interface CMRHostHTMLHandler : CMRHostHandler
@end

@interface CMRMachibbsHandler : CMRHostHTMLHandler
@end

// Described in BSHostLivedoorHandler.m
@interface BSHostLivedoorHandler: CMRHostHTMLHandler
@end

extern NSDictionary *CMRHostPropertiesForKey(NSString *aKey);
