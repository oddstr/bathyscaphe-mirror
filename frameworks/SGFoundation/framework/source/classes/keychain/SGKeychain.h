//: SGKeychain.h
/**
  * $Id: SGKeychain.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>


@interface SGKeychain : NSObject
{
	KCRef		m_keychainRef;
}
+ (id) defaultKeychain;
- (id) initWithKeychainRef : (KCRef) aKeychainRef;
@end



@interface SGKeychain(KeychainManagerWrapper)
+ (BOOL) keychainManagerAvailable;
+ (UInt32) keychainManagerVersion;

+ (NSString *) keychainNameWithKCRef : (KCRef) kcref;
+ (OSStatus) findInternetPasswordWithServerName : (NSString  *) serverName
                                 securityDomain : (NSString  *) securityDomain
                                    accountName : (NSString  *) accountName
                                           path : (NSString  *) path
                                           port : (UInt16     ) port
                                       protocol : (OSType     ) protocol
                                       authType : (OSType     ) authType
                                       password : (NSString **) passwordPtr
                                keychainItemRef : (KCItemRef *) itemRef;
+ (OSStatus) addInternetPasswordWithServerName : (NSString  *) serverName
                                securityDomain : (NSString  *) securityDomain
                                   accountName : (NSString  *) accountName
                                          path : (NSString  *) path
                                          port : (UInt16     ) port
                                      protocol : (OSType     ) protocol
                                      authType : (OSType     ) authType
                                      password : (NSString  *) password
                               keychainItemRef : (KCItemRef *) itemRef;

@end



@interface SGKeychain(ManipulatingKeychainItems)
+ (OSStatus) deleteItem : (KCItemRef) item;
+ (OSStatus) updateItem : (KCItemRef) item;
@end



@interface SGKeychain(StoringAndRetrievingPasswords)
+ (OSType) protocolWithScheme : (NSString *) aScheme;
+ (OSStatus) findInternetPasswordWithURL : (NSURL     *) requestURL
                             accountName : (NSString  *) accountName
                                    port : (UInt16     ) port
                                protocol : (OSType     ) protocol
                                authType : (OSType     ) authType
                                password : (NSString **) passwordPtr
                         keychainItemRef : (KCItemRef *) itemRef;
+ (OSStatus) findInternetPasswordWithURL : (NSURL     *) requestURL
                             accountName : (NSString  *) accountName
                                password : (NSString **) passwordPtr
                         keychainItemRef : (KCItemRef *) itemRef;
+ (NSString *) internetPasswordWithURL : (NSURL     *) requestURL
                           accountName : (NSString  *) accountName;

+ (OSStatus) addInternetPasswordWithURL : (NSURL     *) requestURL
                            accountName : (NSString  *) accountName
                                   port : (UInt16     ) port
                               protocol : (OSType     ) protocol
                               authType : (OSType     ) authType
                               password : (NSString  *) password
                        keychainItemRef : (KCItemRef *) itemRef;
+ (OSStatus) addInternetPasswordWithURL : (NSURL     *) requestURL
                            accountName : (NSString  *) accountName
                               password : (NSString  *) password
                        keychainItemRef : (KCItemRef *) itemRef;
@end



@interface SGKeychain(ItemAttributes)
+ (OSStatus) item : (KCItemRef    ) item
    getAttributes : (KCAttribute *) attrs
     actualLength : (UInt32      *) actualLength;
+ (OSStatus) item : (KCItemRef    ) item
    setAttributes : (KCAttribute *) attrs;

+ (NSString *) Str63AttributeWithItem : (KCItemRef) item 
							   forKey : (OSType   ) tag;
+ (NSString *) accountWithItem : (KCItemRef) item;
+ (NSString *) passwordWithItem : (KCItemRef) item;
	  
+ (OSStatus) item : (KCItemRef ) item
	   setAccount : (NSString *) newAccount;
@end



@interface SGKeychain(ManagingKeychains)
- (NSString *) name;
@end