/* testSQLite */

#import <Cocoa/Cocoa.h>

#import "sqlite3.h"

@protocol SQLiteRow <NSObject>
- (unsigned) columnCount;
- (NSArray *) columnNames;
- (id) valueForColumn : (NSString *) column;
@end

@protocol SQLiteCursor <NSObject>
- (unsigned) columnCount;
- (NSArray *) columnNames;

- (unsigned) rowCount;
- (id) valueForColumn : (NSString *) column atRow : (unsigned) row;
- (NSArray *) valuesForColumn : (NSString *) column;
- (id <SQLiteRow>) rowAtIndex : (unsigned) row;
- (NSArray *) arrayForTableView;
@end

@protocol SQLiteMutableCursor <SQLiteCursor>
- (BOOL) appendRow : (id <SQLiteRow>) row;
- (BOOL) appendCursor : (id <SQLiteCursor>) cursor;
@end

@class SQLiteReservedQuery;

@interface SQLiteDB : NSObject
{
	NSString *mPath;
	sqlite3 *mDatabase;
	
	BOOL _isOpen;
	BOOL _transaction;
}

- (id) initWithDatabasePath : (NSString *) path;

+ (NSString *) prepareStringForQuery : (NSString *) inString;

- (void) setDatabaseFile : (NSString *) path;
- (NSString *) databasePath;

- (sqlite3 *) rowDatabase;

- (BOOL) open;
- (int) close;
- (BOOL) isDatabaseOpen;

- (NSString *) lastError;
- (int) lastErrorID;

- (id <SQLiteMutableCursor>) cursorForSQL : (NSString *) sqlString;
- (id <SQLiteMutableCursor>) performQuery : (NSString *) sqlString; // alias cursorForSQL. for compatible QuickLite.

- (SQLiteReservedQuery *) reservedQuery : (NSString *) sqlString;

@end

@interface SQLiteDB (DatabaseAccessor)

- (NSArray *) tables;

- (BOOL) beginTransaction;
- (BOOL) commitTransaction;
- (BOOL) rollbackTransaction;

- (BOOL) save; // do nothing. for compatible QuickLite.

- (BOOL) createTable : (NSString *) table withColumns : (NSArray *) columns andDatatypes : (NSArray *) datatypes;
- (BOOL) createTemporaryTable : (NSString *) table withColumns : (NSArray *) columns andDatatypes : (NSArray *) datatypes;

- (BOOL) createIndexForColumn : (NSString *) column inTable : (NSString *) table isUnique : (BOOL) isUnique;

@end

@interface SQLiteReservedQuery : NSObject
{
	sqlite3_stmt *m_stmt;
}
+ (id) sqliteReservedQueryWithQuery : (NSString *) sqlString usingSQLiteDB : (SQLiteDB *) db;
- (id) initWithQuery : (NSString *) sqlString usingSQLiteDB : (SQLiteDB *) db;

- (id <SQLiteMutableCursor>) cursorForBindValues : (NSArray *) values;

@end


extern NSString *QLString; // alias TEXT. for compatible QuickLite.
extern NSString *QLNumber; // alias NUMERIC. for compatible QuickLite.
extern NSString *QLDateTime; // alias TEXT. for compatible QuickLite. NOTE : 

extern NSString *INTERGER_PRIMARY_KEY;
extern NSString *TEXT_NOTNULL;
extern NSString *TEXT_UNIQUE;
extern NSString *TEXT_NOTNULL_UNIQUE;
extern NSString *INTEGER_NOTNULL;
extern NSString *INTERGER_UNIQUE;
extern NSString *INTERGER_NOTNULL_UNIQUE;
extern NSString *NUMERIC_NOTNULL;
extern NSString *NUMERIC_UNIQUE;
extern NSString *NUMERIC_NOTNULL_UNIQUE;
extern NSString *NONE_NOTNULL;
extern NSString *NONE_UNIQUE;
extern NSString *NONE_NOTNULL_UNIQUE;
