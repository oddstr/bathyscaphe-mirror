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



// ���������N�̃A�h���X������𐶐��B
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
// be �v���t�B�[�������N�̓����\���p�A�h���X������𐶐��B
NSString *CMRLocalBeProfileLinkWithString(NSString *beProfile)
{
	return [NSString stringWithFormat : @"%@:%@",
		CMRAttributesBeProfileLinkScheme,
		beProfile];
}
