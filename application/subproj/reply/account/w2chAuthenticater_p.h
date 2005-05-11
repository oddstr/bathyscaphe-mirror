//:w2chAuthenticater_p.h
#import "w2chAuthenticater.h"
#import <SGNetwork/SGNetwork.h>
#import "URLConnector_Prefix.h"
#import "SG2chConnector.h"


#import <AppKit/NSPanel.h>
#import "AppDefaults.h"
#import "LoginController.h"



#define X_2CH_SESSION_ID_KEY				
#define USER_AGENT_WHEN_AUTHENTICATION		@"DOLIB/1.00"
#define APP_HTTP_X_2CH_UA_KEY				@"X-2ch-UA"
#define APP_X2CH_ID_PW_FORMAT				@"ID=%@&PW=%@"

		
#define APP_AUTHENTICATER_TABLE				@"AlertMessages"

#define APP_AUTHENTICATER_OK_KEY			@"OKButton"
#define APP_AUTHENTICATER_RETRY_KEY			@"RetryButton"
#define APP_AUTHENTICATER_CANCEL_KEY		@"CancelButton"

#define APP_AUTHENTICATER_ERR_NW_TITLE		@"ERROR_NETWORK"
#define APP_AUTHENTICATER_ERR_NW_MSG		@"Error_Network"
#define APP_AUTHENTICATER_ERR_LOGIN_TITLE	@"ERROR_LOGIN"
#define APP_AUTHENTICATER_ERR_LOGIN_MSG		@"Error_Couldnt_Login"
#define APP_AUTHENTICATER_ERR_CONNECT_TITLE	@"ERROR_CONNECTION"
#define APP_AUTHENTICATER_ERR_CONNECT_MSG	@"Error_Connection_Fail"

@interface w2chAuthenticater(Private)
/* Accessor for m_sessionID */
- (void) setSessionID : (NSString *) aSessionID;
/* Accessor for m_monazillaUserAgent */
- (NSString *) monazillaUserAgent;
- (void) setMonazillaUserAgent : (NSString *) aMonazillaUserAgent;
@end



@interface w2chAuthenticater(Invalidate)
- (BOOL) shouldLogin;
- (BOOL) updateAccountAndPasswordIfNeeded : (NSString **) newAccountPtr
                                 password : (NSString **) newPasswordPtr
					   shouldUsesKeychain : (BOOL	   *) savePassPtr;
- (NSString *) titleKeyForErrorType : (w2chAuthenticaterErrorType) type;
- (NSString *) messageKeyForErrorType : (w2chAuthenticaterErrorType) type;
- (BOOL) invalidate;
@end