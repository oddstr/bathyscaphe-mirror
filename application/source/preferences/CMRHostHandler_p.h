#import "CMRHostHandler.h"
#import "CocoMonar_Prefix.h"


@interface CMRHostHTMLHandler : CMRHostHandler
@end


// dat
@interface CMR2channelHandler : CMRHostHandler
@end
@interface CMR2channelOtherHandler : CMR2channelHandler
@end
@interface CMR2channelBeHandler : CMR2channelHandler
@end

@interface CMRShitarabaHandler : CMRHostHandler
@end

// html
// Removed in BathyScaphe 1.3.1 and later. Use BSHostLivedoorHandler instead.
//@interface CMRJbbsShitarabaHandler : CMRHostHTMLHandler
//@end

// Available in BathyScaphe 1.3.1 and later.
@interface BSHostLivedoorHandler: CMRHostHTMLHandler
@end

@interface CMRMachibbsaHandler : CMRHostHTMLHandler
@end

extern NSDictionary *CMRHostPropertiesForKey(NSString *aKey);
