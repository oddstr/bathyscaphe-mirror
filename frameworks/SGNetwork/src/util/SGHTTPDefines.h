//: SGHTTPDefines.h
/**
  * $Id: SGHTTPDefines.h,v 1.1.1.1 2005/05/11 17:51:50 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */


// Request Method
#define		HTTP_METHOD_GET				@"GET"
#define		HTTP_METHOD_HEAD			@"HEAD"
#define		HTTP_METHOD_POST			@"POST"


/* general-header */
#define		HTTP_CACHE_CONTROL_KEY			@"Cache-Control"
#define		HTTP_CONNECTION_KEY				@"Connection"
#define		HTTP_DATE_KEY					@"Date"
#define		HTTP_PRAGMA_KEY					@"Pragma"
#define		HTTP_TRAILER_KEY				@"Trailer"
#define		HTTP_TRANSFER_ENCODING_KEY		@"Transfer-Encoding"
#define		HTTP_UPGRADE_KEY				@"Upgrade"
#define		HTTP_VIA_KEY					@"Via"
#define		HTTP_WARNING_KEY				@"Warning"
/* request-header */
#define		HTTP_ACCEPT_KEY					@"Accept"
#define		HTTP_ACCEPT_CHARSET_KEY			@"Accept-Charset"
#define		HTTP_ACCEPT_ENCODING_KEY		@"Accept-Encoding"
#define		HTTP_ACCEPT_LANGUAGE_KEY		@"Accept-Language"
#define		HTTP_AUTHORIZATION_KEY			@"Authorization"
#define		HTTP_EXPECT_KEY					@"Expect"
#define		HTTP_FROM_KEY					@"From"
#define		HTTP_HOST_KEY					@"Host"
#define		HTTP_IF_MATCH_KEY				@"If-Match"
#define		HTTP_IF_MODIFIED_SINCE_KEY		@"If-Modified-Since"
#define		HTTP_IF_NONE_MATCH_KEY			@"If-None-Match"
#define		HTTP_IF_RANGE_KEY				@"If-Range"
#define		HTTP_IF_UNMODIFIED_SINCE_KEY	@"If-Unmodified-Since"
#define		HTTP_MAX_FORWARDS_KEY			@"Max-Forwards"
#define		HTTP_PROXY_AUTHORIZATION_KEY	@"Proxy-Authorization"
#define		HTTP_RANGE_KEY					@"Range"
#define		HTTP_REFERER_KEY				@"Referer"
#define		HTTP_TE_KEY						@"TE"
#define		HTTP_USER_AGENT_KEY				@"User-Agent"
/* response-header */
#define		HTTP_ACCEPT_RANGES_KEY			@"Accept-Ranges"
#define		HTTP_AGE_KEY					@"Age"
#define		HTTP_ETAG_KEY					@"ETag"
#define		HTTP_LOCATION_KEY				@"Location"
#define		HTTP_PROXY_AUTHENTICATE_KEY		@"Proxy-Authenticate"
#define		HTTP_RETRY_AFTER_KEY			@"Retry-After"
#define		HTTP_SERVER_KEY					@"Server"
#define		HTTP_VARY_KEY					@"Vary"
#define		HTTP_WWW_AUTHENTICATE_KEY		@"WWW-Authenticate"
/* entity-header */
#define		HTTP_ALLOW_KEY					@"Allow"
#define		HTTP_CONTENT_ENCODING_KEY		@"Content-Encoding"
#define		HTTP_CONTENT_LANGUAGE_KEY		@"Content-Language"
#define		HTTP_CONTENT_LENGTH_KEY			@"Content-Length"
#define		HTTP_CONTENT_LOCATION_KEY		@"Content-Location"
#define		HTTP_CONTENT_MD5_KEY			@"Content-MD5"
#define		HTTP_CONTENT_RANGE_KEY			@"Content-Range"
#define		HTTP_CONTENT_TYPE_KEY			@"Content-Type"
#define		HTTP_EXPIRES_KEY				@"Expires"
#define		HTTP_LAST_MODIFIED_KEY			@"Last-Modified"
#define		HTTP_EXTENSION_HEADER_KEY		@"extension-header"


#define		HTTP_COOKIE_HEADER_KEY			@"Cookie"
#define		HTTP_SET_COOKIE_HEADER_KEY		@"Set-Cookie"



// Transfer-Encoding
#define		HTTP_TRANSFER_CHUNKED_ENCODING	@"chunked"


// Content-Type
#define		HTTP_CONTENT_URL_ENCODED_TYPE	@"application/x-www-form-urlencoded"



// StatusCode
enum {
	HTTP_OK									= 200,
	HTTP_PERTIAL							= 206,
	HTTP_NOT_MODIFIED						= 304,
	HTTP_UNAUTHORIZED						= 401,
	HTTP_PROXY_AUTHENTICATION_REQUIRED		= 407,
	HTTP_RANGE_NOT_SATISFIABLE				= 416
};

