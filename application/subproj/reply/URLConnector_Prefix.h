#import <SGFoundation/SGFoundation.h>
#import <SGNetwork/SGNetwork.h>
#import <CocoMonar/CocoMonar.h>

#import "UTILKit.h"



#define PLUGIN_BUNDLE	[NSBundle bundleForClass : [SG2chConnector class]]
#define PluginLocalizedStringFromTable(key, tableName, comment)		\
	NSLocalizedStringFromTableInBundle(key, tableName, PLUGIN_BUNDLE, comment)


/* Localizable.strings */
#define kAlertTableName				nil

#define w2chLocalizedAlertMessageString(key)	\
PluginLocalizedStringFromTable(key, kAlertTableName, nil)
