//:CMRMessageAttributesStyling.m
#import "CMRMessageAttributesStyling.h"

NSString *const CMRAttributeInnerLinkScheme = @"cmonar";
NSString *const CMRAttributesBeProfileLinkScheme = @"cmbe";

/*** Application Specific Attribute Name ***/
NSString *const CMRMessageIndexAttributeName = @"CMRIndex";

/* These attributes are for text attachements. */
NSString *const CMRMessageLastUpdatedHeaderAttributeName = @"CMRLastUpdated";
NSString *const CMRMessageProxyAttributeName = @"CMRMessageProxy";
NSString *const CMRMessageBeProfileLinkAttributeName = @"CMRBeProfileLink";



// 内部リンクのアドレス文字列を生成。
NSString *CMRLocalResLinkWithString(NSString *address)
{
	return [NSString stringWithFormat : @"%@:%@",
		CMRAttributeInnerLinkScheme,
		address];
}
/* 0-based */
NSString *CMRLocalResLinkWithIndex(unsigned anIndex)
{
	return [NSString stringWithFormat : @"%@:%u",
		CMRAttributeInnerLinkScheme,
		anIndex +1];
}
// be プロフィールリンクの内部表現用アドレス文字列を生成。
NSString *CMRLocalBeProfileLinkWithString(NSString *beProfile)
{
	return [NSString stringWithFormat : @"%@:%@",
		CMRAttributesBeProfileLinkScheme,
		beProfile];
}
