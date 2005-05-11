//: SGKeychain.m
/**
  * $Id: SGKeychain.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGKeychain_p.h"


static NSLock	*st_singletonLock = nil;

@implementation SGKeychain
+ (void) initialize
{
	static BOOL st_isFirstInvocation = YES;
	if(st_isFirstInvocation)
		st_singletonLock = [[NSLock alloc] init];
	st_isFirstInvocation = NO;
}

+ (id) defaultKeychain
{
	static id	st_instance = nil;
	
	if(NO == [[self class] keychainManagerAvailable]) 
		return nil;
	
	if(nil == st_instance){
		[st_singletonLock lock];
		if(nil == st_instance){
			OSStatus	status_;
			KCRef		defaultKeychain_;
			
			status_ = KCGetDefaultKeychain(&defaultKeychain_);
			if(errKCNoDefaultKeychain == status_) return nil;
			
			st_instance = [[self alloc] initWithKeychainRef : defaultKeychain_];
		}
		[st_singletonLock unlock];
	}
	return st_instance;
}

+ (id) allocWithZone : (NSZone *) zone
{
	if(NO == [[self class] keychainManagerAvailable])
		return nil;
	return [super allocWithZone : zone];
}

- (id) initWithKeychainRef : (KCRef) aKeychainRef;
{
	if(self = [self init]){
		m_keychainRef = aKeychainRef;
	}
	return self;
}

- (void) dealloc
{
	OSStatus	status_;
	
	// NSLog(@"KCReleaseKeychain");
	status_ = KCReleaseKeychain(&m_keychainRef);
	m_keychainRef = NULL;
	// NSLog(@"Status = %d.", status_);
	
	[super dealloc];
}
@end



@implementation SGKeychain(KeychainManagerVersion)
+ (BOOL) keychainManagerAvailable
{
	return KeychainManagerAvailable();
}
+ (UInt32) keychainManagerVersion
{
	UInt32		keychainManagerVersion_;
	OSStatus	status_;
	
	status_ = KCGetKeychainManagerVersion(&keychainManagerVersion_);
	if(status_ != noErr) return 0;
	
	return keychainManagerVersion_;
}

+ (NSString *) keychainNameWithKCRef : (KCRef) kcref
{
	Str255			str255_;
	OSStatus		status_;
	
	if(NULL == kcref) return nil;
	
	status_ = KCGetKeychainName(
						kcref,
						str255_);
	
	if(errKCInvalidKeychain == status_) return nil;
	if(status_ != noErr) return nil;
	
	return [NSString stringWithPascalString : str255_];
}


#define PRV_COPY_PLSTR(str, buffer)		\
do{if(str != nil){\
	if(NO == [str getPascalString:buffer maxLength:UTILNumberOfCArray(buffer)]){\
		buffer[0] = NULL;\
	}\
}else{\
	buffer[0] = NULL;\
}}while(0)
+ (OSStatus) findInternetPasswordWithServerName : (NSString  *) serverName
                                 securityDomain : (NSString  *) securityDomain
                                    accountName : (NSString  *) accountName
                                           path : (NSString  *) path
                                           port : (UInt16     ) port
                                       protocol : (OSType     ) protocol
                                       authType : (OSType     ) authType
                                       password : (NSString **) passwordPtr
                                keychainItemRef : (KCItemRef *) itemRef
{
	OSStatus	status_;

	Str255		serverName_;
	Str255		securityDomain_;
	Str255		accountName_;
	Str255		path_;

	Str255		pStr_;
	UInt32		actualLength_;
	
	if(passwordPtr != NULL) *passwordPtr = nil;
	
	PRV_COPY_PLSTR(serverName, serverName_);
	PRV_COPY_PLSTR(securityDomain, securityDomain_);
	PRV_COPY_PLSTR(accountName, accountName_);
	PRV_COPY_PLSTR(path, path_);
	
	status_ = KCFindInternetPasswordWithPath (
					serverName_, 
					securityDomain_, 
					accountName_, 
					path_, 
					port,
					protocol,
					authType,
					UTILNumberOfCArray(pStr_),
					pStr_,
					&actualLength_,
					itemRef);
	if(status_ != noErr) return status_;
	
	
	if(passwordPtr != NULL)
		*passwordPtr = [NSString stringWithCString:pStr_ length:actualLength_];
	
	return status_;
}
+ (OSStatus) addInternetPasswordWithServerName : (NSString  *) serverName
                                securityDomain : (NSString  *) securityDomain
                                   accountName : (NSString  *) accountName
                                          path : (NSString  *) path
                                          port : (UInt16     ) port
                                      protocol : (OSType     ) protocol
                                      authType : (OSType     ) authType
                                      password : (NSString  *) password
                               keychainItemRef : (KCItemRef *) itemRef
{
	Str255		serverName_;
	Str255		securityDomain_;
	Str255		accountName_;
	Str255		path_;
	
	PRV_COPY_PLSTR(serverName, serverName_);
	PRV_COPY_PLSTR(securityDomain, securityDomain_);
	PRV_COPY_PLSTR(accountName, accountName_);
	PRV_COPY_PLSTR(path, path_);
	

	return KCAddInternetPasswordWithPath(
					serverName_, 
					securityDomain_, 
					accountName_, 
					path_, 
					port,
					protocol,
					authType,
					[password cStringLength],
					[password cString],
					itemRef);
}
#undef PRV_COPY_PLSTR
@end



@implementation SGKeychain(ManipulatingKeychainItems)
+ (OSStatus) deleteItem : (KCItemRef) item
{
	return KCDeleteItem(item);
}
+ (OSStatus) updateItem : (KCItemRef) item
{
	return KCUpdateItem(item);
}
@end



@implementation SGKeychain(StoringAndRetrievingPasswords)
+ (OSType) protocolWithScheme : (NSString *) aScheme
{
	if([aScheme hasPrefix : @"http"]) return kKCProtocolTypeHTTP;
	if([aScheme isEqualToString : @"ftp"]) return kKCProtocolTypeFTP;
	if([aScheme isEqualToString : @"ftpa"]) return kKCProtocolTypeFTPAccount;
	if([aScheme isEqualToString : @"pop"]) return kKCProtocolTypePOP3;
	if([aScheme isEqualToString : @"smtp"]) return kKCProtocolTypeSMTP;
	if([aScheme isEqualToString : @"afp"]) return kKCProtocolTypeAFP;
	
	return kKCProtocolTypeHTTP;
}
+ (OSStatus) findInternetPasswordWithURL : (NSURL     *) requestURL
                             accountName : (NSString  *) accountName
                                    port : (UInt16     ) port
                                protocol : (OSType     ) protocol
                                authType : (OSType     ) authType
                                password : (NSString **) passwordPtr
                         keychainItemRef : (KCItemRef *) itemRef
{
	return [self findInternetPasswordWithServerName : [requestURL host]
				securityDomain : nil
				accountName : accountName
				path : [requestURL path]
				port : port
				protocol : protocol
				authType : authType
				password : passwordPtr
				keychainItemRef : itemRef];
}
+ (OSStatus) findInternetPasswordWithURL : (NSURL     *) requestURL
                             accountName : (NSString  *) accountName
                                password : (NSString **) passwordPtr
                         keychainItemRef : (KCItemRef *) itemRef
{
	return [self findInternetPasswordWithURL : requestURL
                     accountName : accountName
                            port : kAnyPort
                        protocol : [self protocolWithScheme : [requestURL scheme]]
                        authType : kAnyAuthType
                        password : passwordPtr
                 keychainItemRef : itemRef];
}

+ (NSString *) internetPasswordWithURL : (NSURL     *) requestURL
                           accountName : (NSString  *) accountName
{
	NSString		*password_;
	OSStatus		status_;
	
	status_ = [self findInternetPasswordWithURL : requestURL
							accountName : accountName
							password : &password_
							keychainItemRef : NULL];
	if(status_ != noErr) return nil;
	
	return password_;
}


+ (OSStatus) addInternetPasswordWithURL : (NSURL     *) requestURL
                            accountName : (NSString  *) accountName
                                   port : (UInt16     ) port
                               protocol : (OSType     ) protocol
                               authType : (OSType     ) authType
                               password : (NSString  *) password
                        keychainItemRef : (KCItemRef *) itemRef
{
	return [self addInternetPasswordWithServerName : [requestURL host]
				securityDomain : nil
				accountName : accountName
				path : [requestURL path]
				port : port
				protocol : protocol
				authType : authType
				password : password
				keychainItemRef : itemRef];
}
+ (OSStatus) addInternetPasswordWithURL : (NSURL     *) requestURL
                            accountName : (NSString  *) accountName
                               password : (NSString  *) password
                        keychainItemRef : (KCItemRef *) itemRef
{
	return [self addInternetPasswordWithURL : requestURL
                     accountName : accountName
                            port : kAnyPort
                        protocol : [self protocolWithScheme : [requestURL scheme]]
                        authType : kKCAuthTypeDefault
                        password : password
                 keychainItemRef : itemRef];
}

@end



@implementation SGKeychain(ItemAttributes)
+ (OSStatus) item : (KCItemRef    ) item
    getAttributes : (KCAttribute *) attrs
     actualLength : (UInt32      *) actualLength
{
	return KCGetAttribute(item, attrs, actualLength);
}
+ (OSStatus) item : (KCItemRef    ) item
    setAttributes : (KCAttribute *) attrs
{
	return KCSetAttribute(item, attrs);
}

+ (NSString *) Str63AttributeWithItem : (KCItemRef) item 
							   forKey : (OSType   ) tag
{
	OSStatus		status_;
	KCAttribute		attr_;
	UInt32			actualLength_;
	Str255			pstr_;
	
	attr_.tag = tag;
	attr_.length = UTILNumberOfCArray(pstr_);
	attr_.data = pstr_;
	
	status_ = [self      item : item
				getAttributes : &attr_
				 actualLength : &actualLength_];
	
	NSLog(@"status_ = %d", status_);
	if(status_ != noErr) return nil;
	NSLog(@"actualLength_ = %d", actualLength_);
	
	return [NSString stringWithCString : pstr_
								length : actualLength_];
}
+ (NSString *) accountWithItem : (KCItemRef) item
{
	return [self Str63AttributeWithItem:item forKey:kAccountKCItemAttr];
}
+ (NSString *) passwordWithItem : (KCItemRef) item
{
	return [self Str63AttributeWithItem:item forKey:kGenericKCItemAttr];
}



+ (OSStatus) item : (KCItemRef) item
	   setAccount : (NSString *) newAccount
{
	OSStatus		status_;
	KCAttribute		attr_;
	Str63			pstr_;
	
	status_ = KCUnlock(NULL, NULL);
	if(status_ != noErr) return status_;
	
	[newAccount getCString:pstr_
				 maxLength:UTILNumberOfCArray(pstr_)];
	attr_.tag = kAccountKCItemAttr;
	attr_.length = [newAccount cStringLength];
	attr_.data = pstr_;
	
	return [self item:item setAttributes:&attr_];
}
@end



@implementation SGKeychain(ManagingKeychains)
- (NSString *) name
{
	return [[self class] keychainNameWithKCRef : m_keychainRef];
}
@end
