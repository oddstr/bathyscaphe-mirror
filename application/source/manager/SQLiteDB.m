//
//  SQLiteDB.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/12/12.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "SQLiteDB.h"

#import "sqlite3.h"

#import <sys/time.h>

@interface NSDictionary (SQLiteRow) <SQLiteRow>
@end
@interface NSMutableDictionary (SQLiteMutableCursor) <SQLiteMutableCursor>
@end

@implementation SQLiteDB


static NSString *TestColumnNames = @"ColumnNames";
static NSString *TestValues = @"Values";


NSString *QLString = @"TEXT";
NSString *QLNumber = @"NUMERIC";
NSString *QLDateTime = @"TEXT";

NSString *INTERGER_PRIMARY_KEY =@"INTEGER PRIMARY KEY";

NSString *TEXT_NOTNULL = @"TEXT NOT NULL";
NSString *TEXT_UNIQUE = @"TEXT UNIQUE";
NSString *TEXT_NOTNULL_UNIQUE = @"TEXT UNIQUE NOT NULL";
NSString *INTEGER_NOTNULL = @"INTEGER NOT NULL";
NSString *INTEGER_UNIQUE = @"INTEGER UNIQUE";
NSString *INTEGER_NOTNULL_UNIQUE = @"INTEGER UNIQUE NOT NULL";
NSString *NUMERIC_NOTNULL = @"NUMERIC NOT NULL";
NSString *NUMERIC_UNIQUE = @"NUMERIC UNIQUE";
NSString *NUMERIC_NOTNULL_UNIQUE = @"NUMERIC UNIQUE NOT NULL";
NSString *NONE_NOTNULL = @"NOT NULL";
NSString *NONE_UNIQUE = @"UNIQUE";
NSString *NONE_NOTNULL_UNIQUE = @"UNIQUE NOT NULL";

double debug_clock()
{
	double t;
	struct timeval tv;
	gettimeofday(&tv, NULL);
	t = tv.tv_sec + (double)tv.tv_usec*1e-6;
	return t;
}
void debug_log(const char *p,...)
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	
	if([d boolForKey:@"SQLITE_DEBUG_LOG"]) {
		va_list args;
		va_start(args, p);
		vfprintf(stderr, p, args);
	}
}
void debug_log_time(double t1, double t2)
{
	debug_log( "total time : \t%02.4lf\n",(t2) - (t1));
}

int progressHandler(void *obj)
{
	//	NSLog(@"Enter progressHandler ->%@", obj);
	
	return SQLITE_OK;
}

+ (NSString *) prepareStringForQuery : (NSString *) inString
{
	NSString *str;
	const char *p;
	char *q;
	
	p = [inString UTF8String];
	q = sqlite3_mprintf("%q", p);
	str = [NSString stringWithUTF8String : q];
	sqlite3_free(q);
	
	return str;
}

- (id) initWithDatabasePath : (NSString *) path
{
	if (self = [super init]) {
		[self setDatabaseFile : path];
		_isOpen = NO;
	}
	
	return self;
}

- (void) dealloc
{
	[self close];
	[mPath release];
	
	[super dealloc];
}

- (NSString *) lastError
{
	if (!mDatabase) return nil;
	
	return [NSString stringWithUTF8String : sqlite3_errmsg(mDatabase)];
}
- (int) lastErrorID
{
	if (!mDatabase) return nil;
	
	return sqlite3_errcode(mDatabase);
}

- (void) setDatabaseFile : (NSString *) path
{
	id temp = mPath;
	mPath = [path copy];
	[temp release];
	
	[self open];
}
- (NSString *) databasePath
{
	return [NSString stringWithString : mPath];
}

- (sqlite3 *) rowDatabase
{
	return mDatabase;
}

- (BOOL) open
{
	const char *filepath = [mPath fileSystemRepresentation];
	int result;
	
	if ([self isDatabaseOpen]) {
		[self close];
	}
	
	UTILDebugWrite(@"Start Open database.");
	result = sqlite3_open(filepath, &mDatabase);
	if(result != SQLITE_OK) {
		NSLog(@"Can not open database. \nFile -> %@.\nError Code : %d", mPath, result);
		[mPath release];
		mPath = nil;
		mDatabase = NULL;
		
		return NO;
	}/* else {
		sqlite3_progress_handler(mDatabase, 1, progressHandler, self);
	}*/
	
	_isOpen = YES;
	
	return YES;
}
- (int) close
{
	int result = NO;
	
	if (mDatabase) {
		NSLog(@"Start Closing database.");
		do {
			result = sqlite3_close(mDatabase);
		} while (result == SQLITE_BUSY);
		mDatabase = NULL;
		
		NSLog(@"End Closing database.");
	}
	
	_isOpen = NO;
	
	return result;
}
- (BOOL) isDatabaseOpen
{
	return _isOpen;
}

id <SQLiteRow> makeRowFromSTMT(sqlite3_stmt *stmt, NSArray *columns)
{
	NSNull *nsNull = [NSNull null];
	
	CFMutableDictionaryRef result;
	int i, columnCount = sqlite3_column_count(stmt);
	
	result = CFDictionaryCreateMutable(kCFAllocatorDefault,
									   columnCount,
									   &kCFTypeDictionaryKeyCallBacks,
									   &kCFTypeDictionaryValueCallBacks);
	if(!result) return nil;
	
	for (i = 0; i < columnCount; i++) {
		//		const char *columnName = sqlite3_column_name(stmt, i);
		const unsigned char *value = sqlite3_column_text(stmt, i);
		id v = nil;
		
		if (value) {
			v = (id)CFStringCreateWithCString(kCFAllocatorDefault,
											  (const char*)value,
											  kCFStringEncodingUTF8);
		}
		if (v) {
			CFDictionaryAddValue(result, CFArrayGetValueAtIndex((CFArrayRef)columns, i), v);
		}
		
		
		if(v && v != nsNull) {
			CFRelease(v);
		}
	}
	
	return [(id)result autorelease];
}

NSArray *columnsFromSTMT(sqlite3_stmt *stmt)
{
	CFMutableArrayRef result;
	int i, columnCount = sqlite3_column_count(stmt);
	
	result = CFArrayCreateMutable(kCFAllocatorDefault,
								  columnCount,
								  &kCFTypeArrayCallBacks);
	if(!result) return nil;
	
	for (i = 0; i < columnCount; i++) {
		const char *columnName = sqlite3_column_name(stmt, i);
		CFStringRef colStr;
		CFMutableStringRef lowerColStr; 
		
		colStr = CFStringCreateWithCString(kCFAllocatorDefault,
										   columnName,
										   kCFStringEncodingUTF8);
		lowerColStr = CFStringCreateMutableCopy(kCFAllocatorDefault,
												CFStringGetLength(colStr),
												colStr);
		CFStringLowercase(lowerColStr, CFLocaleGetSystem());
		CFArrayAppendValue(result, lowerColStr);
		CFRelease(colStr);
		CFRelease(lowerColStr);
	}
	
	return [(id)result autorelease];
}

NSArray *valuesForSTMT(sqlite3_stmt *stmt, NSArray *culumns)
{
	int result;
	BOOL finishFetch = NO;
	id <SQLiteRow> dict;
	CFMutableArrayRef values;
	
	values = CFArrayCreateMutable(kCFAllocatorDefault,
								  0,
								  &kCFTypeArrayCallBacks);
	if(!values) return nil;
	
	do {
		BOOL updateCursor = NO;
		
		result = sqlite3_step(stmt);
		
		switch (result) {
			case SQLITE_BUSY :
				break;
			case SQLITE_OK :
			case SQLITE_DONE :
				finishFetch = YES;
				break;
			case SQLITE_ROW :
				updateCursor = YES;
				break;
			case SQLITE_SCHEMA:
				continue;
			default :
				//				sqlite3_finalize(stmt);
				return nil;
				break;
		}
		
		if (updateCursor) {
			dict = makeRowFromSTMT(stmt, culumns);
			if (dict) {
				CFArrayAppendValue(values, dict);
			}
		}
		
	} while (!finishFetch);
	
	return [(id)values autorelease];
}

id<SQLiteMutableCursor> cursorFromSTMT(sqlite3_stmt *stmt)
{
	id columns, values;
	id<SQLiteMutableCursor> cursor;
	
	double time00, time01;

	time00 = debug_clock();
	columns = columnsFromSTMT(stmt);
	values = valuesForSTMT(stmt, columns);
	time01 = debug_clock();
	debug_log_time(time00, time01);
	
	if(!columns || !values) {
		return nil;
	}
	cursor = [NSDictionary dictionaryWithObjectsAndKeys : columns, TestColumnNames,
		values, TestValues, nil];
	
	return cursor;
}

- (id <SQLiteMutableCursor>) cursorForSQL : (NSString *) sqlString
{
	const char *sql;
	sqlite3_stmt *stmt;
	int result;
	id <SQLiteMutableCursor> cursor;
	
	if (!mDatabase) {
		return nil;
	}
	if (!sqlString) {
		return nil;
	}
	
	sql = [sqlString UTF8String];
	
	result = sqlite3_prepare(mDatabase, sql, strlen(sql) , &stmt, &sql);
	if(result != SQLITE_OK) return nil;
	
	debug_log("send query %s\n", [sqlString UTF8String]);
	
	cursor = cursorFromSTMT(stmt);
	sqlite3_finalize(stmt);
	
	return cursor;
}

- (id <SQLiteMutableCursor>) performQuery : (NSString *) sqlString
{
	return [self cursorForSQL : sqlString];
}

- (SQLiteReservedQuery *) reservedQuery : (NSString *) sqlString
{
	return [SQLiteReservedQuery sqliteReservedQueryWithQuery : sqlString usingSQLiteDB : self];
}
@end

@implementation SQLiteDB (DatabaseAccessor)

- (NSArray *) tables
{
	id cursor;
	id sql = [NSString stringWithFormat : @"%s", 
		"SELECT name FROM sqlite_master WHERE type = 'table' OR type = 'view'	\
	UNION	\
	SELECT name FROM sqlite_temp_master	\
	WHERE type = 'table' OR type = 'view'"];
	
	cursor = [self cursorForSQL : sql];
	
	return [cursor valuesForColumn : @"Name"];
}
- (BOOL) beginTransaction
{
	if (_transaction) {
		NSLog(@"Already begin transaction.");
		
		return NO;
	}
	
	_transaction = YES;
	
	[self performQuery : @"BEGIN"];
	
	return [self lastErrorID] == 0;
}
- (BOOL) commitTransaction
{
	if (!_transaction) {
		NSLog(@"Not begin transaction.");
		
		return NO;
	}
	
	_transaction = NO;
	
	[self performQuery : @"COMMIT"];
	
	return [self lastErrorID] == 0;
}
- (BOOL) rollbackTransaction
{
	if (!_transaction) {
		NSLog(@"Not begin transaction.");
		
		return NO;
	}
	
	_transaction = NO;
	
	[self performQuery : @"ROLLBACK"];
	
	return [self lastErrorID] == 0;
}

// do nothing. for compatible QuickLite.
- (BOOL) save { return YES; }

- (NSString *) defaultValue : (id) inValue forDatatype : (NSString *) datatype
{
	NSString *defaultValue = nil;
	
	if(!inValue || inValue == [NSNull null]) {
		return nil;
	}
	
	if(!datatype || (id)datatype == [NSNull null]) {
		defaultValue =  [[self class] prepareStringForQuery : [inValue stringValue]];
	}
	
	NSRange range;
	NSString *lower = [datatype lowercaseString];
	
	range = [lower rangeOfString : @"text"];
	if(range.length != 0) {
		defaultValue = [NSString stringWithFormat : @"'%@'", [[self class] prepareStringForQuery : [inValue stringValue]]];
	}
	
	range = [lower rangeOfString : @"integer"];
	if(range.length != 0) {
		defaultValue =  [NSString stringWithFormat : @"%d", [inValue intValue]];
	}
	
	range = [lower rangeOfString : @"numelic"];
	if(range.length != 0) {
		defaultValue =  [NSString stringWithFormat : @"%0.0f", [inValue floatValue]];
	}
	
	if(defaultValue) {
		return [NSString stringWithFormat : @"DEFAULT %@", defaultValue];
	}
	
	return nil;
}

- (NSString *) checkConstraint : (id) checkConstraint
{
	if(!checkConstraint || checkConstraint == [NSNull null]) {
		return nil;
	}
	
	return [NSString stringWithFormat : @"CHECK(%@)", checkConstraint];;
}

- (BOOL) createTemporaryTable : (NSString *) table
					  columns : (NSArray *) columns
					datatypes : (NSArray *) datatypes
				defaultValues : (NSArray *) defaultValues
			  checkConstrains : (NSArray *) checkConstrains
				  isTemporary : (BOOL) isTemporary
{
	unsigned i;
	unsigned columnCount = [columns count];
	NSMutableString *sql;
	BOOL useDefaultValues = NO;
	BOOL useCheck = NO;
	
	if (columnCount != [datatypes count]) return NO;
	if (columnCount == 0) return NO;
	
	useDefaultValues = defaultValues ? YES :NO;
	if(useDefaultValues && columnCount != [defaultValues count]) return NO;
	useCheck = checkConstrains ? YES :NO;
	if(useDefaultValues && columnCount != [checkConstrains count]) return NO;
	
	sql = [NSMutableString stringWithFormat : @"CREATE %@ TABLE %@ (",
				 isTemporary ? @"TEMPORARY" : @"", table];
	
	for (i = 0; i < columnCount; i++) {
		[sql appendFormat : @"%@ %@", [columns objectAtIndex : i], [datatypes objectAtIndex : i]];
		if(useDefaultValues) {
			NSString *d = [self defaultValue: [defaultValues objectAtIndex : i ]
								forDatatype : [datatypes objectAtIndex : i]];
			if(d) {
				[sql appendFormat : @" %@", d];
			}
		}
		if(useCheck) {
			NSString *c = [self checkConstraint : [checkConstrains objectAtIndex : i ]];
			if(c && (id)c != [NSNull null]) {
				[sql appendFormat : @" %@", c];
			}
		}
		
		if (i != columnCount - 1) {
			[sql appendString : @","];
		}
	}
	[sql appendString : @") "];
	
	[self performQuery : sql];
	
	return [self lastErrorID] == 0;
}


- (BOOL) createTable : (NSString *) table
	     withColumns : (NSArray *) columns
	    andDatatypes : (NSArray *) datatypes
	     isTemporary : (BOOL) isTemporary
{
	return [self createTemporaryTable : table
							  columns : columns
							datatypes : datatypes
						defaultValues : nil
					  checkConstrains : nil
						  isTemporary : NO];
}
- (BOOL) createTable : (NSString *) table withColumns : (NSArray *) columns andDatatypes : (NSArray *) datatypes
{
	return [self createTable : table
				 withColumns : columns
				andDatatypes : datatypes
				 isTemporary : NO];
}
- (BOOL) createTable : (NSString *) table
			 columns : (NSArray *) columns
		   datatypes : (NSArray *) datatypes
	   defaultValues : (NSArray *)defaultValues
	 checkConstrains : (NSArray *)checkConstrains
{
	return [self createTemporaryTable : table
							  columns : columns
							datatypes : datatypes
						defaultValues : defaultValues
					  checkConstrains : checkConstrains
						  isTemporary : NO];
}
- (BOOL) createTemporaryTable : (NSString *) table
				  withColumns : (NSArray *) columns
			     andDatatypes : (NSArray *) datatypes
{
	return [self createTable : table
				 withColumns : columns
				andDatatypes : datatypes
				 isTemporary : YES];
}
- (BOOL) createTemporaryTable : (NSString *) table
					  columns : (NSArray *) columns
					datatypes : (NSArray *) datatypes
				defaultValues : (NSArray *)defaultValues
			  checkConstrains : (NSArray *)checkConstrains
{
	return [self createTemporaryTable : table
							  columns : columns
							datatypes : datatypes
						defaultValues : defaultValues
					  checkConstrains : checkConstrains
						  isTemporary : YES];
}

- (NSString *)indexNameForColumn:(NSString *)column inTable:(NSString *)table
{
	return [NSString stringWithFormat:@"%@_%@_INDEX", table, column];
}
- (BOOL) createIndexForColumn : (NSString *) column inTable : (NSString *) table isUnique : (BOOL) isUnique
{
	NSString *sql;
	
	sql = [NSString stringWithFormat : @"CREATE %@ INDEX %@ ON %@ ( %@ ) ",
				isUnique ? @"UNIQUE" : @"",
				[self indexNameForColumn:column inTable:table], 
				table, column];
	
	[self performQuery : sql];
	
	return [self lastErrorID] == 0;
}

- (BOOL) deleteIndexForColumn:(NSString *)column inTable:(NSString *)table
{
	NSString *sql;
	
	sql = [NSString stringWithFormat : @"DROP INDEX %@",
		[self indexNameForColumn:column inTable:table]];
	
	[self performQuery : sql];
	
	return [self lastErrorID] == 0;
}

@end

@implementation SQLiteReservedQuery

+ (id) sqliteReservedQueryWithQuery : (NSString *) sqlString usingSQLiteDB : (SQLiteDB *) db
{
	return [[[self alloc] initWithQuery : sqlString usingSQLiteDB : db] autorelease];
}

- (id) initWithQuery : (NSString *) sqlString usingSQLiteDB : (SQLiteDB *) db
{
	self = [super init];
	
	if (self) {
		const char *sql = [sqlString UTF8String];
		int result;
		
		result = sqlite3_prepare([db rowDatabase], sql, strlen(sql) , &m_stmt, &sql);
		if (result != SQLITE_OK) goto fail;
		
		debug_log("create statment %s\n", [sqlString UTF8String]);
	}
	
	return self;
	
fail :
		[self release];
	return nil;
}

- (void) dealloc
{
	sqlite3_finalize(m_stmt);
	
	[super dealloc];
}

void objectDeallocator(void *obj)
{
	//	NSLog(@"??? DEALLOC ???");
}
- (id <SQLiteMutableCursor>) cursorForBindValues : (NSArray *) bindValues
{
	int error;
	int paramCount;
	unsigned i, valuesCount;
	id value;
	
	id <SQLiteMutableCursor> cursor;
	
	error = sqlite3_reset(m_stmt);
	if (SQLITE_OK != error) return nil;
	error = sqlite3_clear_bindings(m_stmt);
	if (SQLITE_OK != error) return nil;
	
	valuesCount = [bindValues count];
	paramCount = sqlite3_bind_parameter_count(m_stmt);
	if (valuesCount != paramCount) {
		NSLog(@"Missmatch bindValues count!!");
		return nil;
	}
	for (i = 0; i < valuesCount; i++) {
		value = [bindValues objectAtIndex : i];
		
		if ([value isKindOfClass : [NSNumber class]]) {
			int intValue = [value intValue];
			error = sqlite3_bind_int(m_stmt, i+1, intValue);
			if (SQLITE_OK != error) return nil;
		} else if ([value isKindOfClass : [NSString class]]) {
			const char *str = [value UTF8String];
			error = sqlite3_bind_text(m_stmt, i+1, str, strlen(str) , objectDeallocator);
			if (SQLITE_OK != error) return nil;
		} else if (value == [NSNull null]) {
			error = sqlite3_bind_null(m_stmt, i+1);
			if (SQLITE_OK != error) return nil;
		} else {
			NSLog(@"cursorForBindValues : NOT supported type.");
			return nil;
		}
	}
	
	cursor = cursorFromSTMT(m_stmt);
	
	error = sqlite3_reset(m_stmt);
	
	return cursor;
}

@end

@implementation NSDictionary (SQLiteRow)
- (unsigned) columnCount
{
	return [self count];
}
- (NSArray *) columnNames
{
	return [self allKeys];
}
- (id) valueForColumn : (NSString *) column
{
	NSString *lower = [column lowercaseString];
	id result = [self objectForKey : lower];
	return result ? result : [NSNull null];
}
@end

@implementation NSMutableDictionary (SQLiteCursor)

- (unsigned) columnCount
{
	return [[self objectForKey : TestColumnNames] count];
}
- (NSArray *) columnNames
{
	return [self objectForKey : TestColumnNames];
}

- (unsigned) rowCount
{
	return [[self objectForKey : TestValues] count];
}
- (id) valueForColumn : (NSString *) column atRow : (unsigned) row
{
	id lower = [column lowercaseString];
	return [[self rowAtIndex : row] valueForColumn : lower];
}
- (NSArray *) valuesForColumn : (NSString *) column;
{
	id lower = [column lowercaseString];
	NSMutableArray *result;
	unsigned i, rowCount = [self rowCount];
	
	if (rowCount == 0 || [self columnCount] == 0) return nil;
	
	result = [NSMutableArray arrayWithCapacity : rowCount];
	for (i = 0; i < rowCount; i++) {
		id value = [self valueForColumn : lower atRow : i];
		if (value) {
			[result addObject : value];
		}
	}
	
	return result;
}
- (id <SQLiteRow>) rowAtIndex : (unsigned) row
{
	return [[self arrayForTableView] objectAtIndex : row];
}
- (NSArray *) arrayForTableView
{
	id result = [self objectForKey : TestValues];
	
	if (!result) {
		result = [NSMutableArray array];
		[self setObject : result forKey : TestValues];
	}
	
	return result;
}

- (BOOL) appendRow : (id <SQLiteRow>) row
{
	if ([row columnCount] != [self columnCount]) return NO;
	if (![[row columnNames] isEqual : [self columnNames]]) return NO;
	
	[(NSMutableArray *)[self arrayForTableView] addObject : row];
	
	return YES;
}
- (BOOL) appendCursor : (id <SQLiteCursor>) cursor
{
	if ([cursor columnCount] != [self columnCount]) return NO;
	if (![[cursor columnNames] isEqual : [self columnNames]]) return NO;
	
	[(NSMutableArray *)[self arrayForTableView] addObjectsFromArray : [cursor arrayForTableView]];
	
	return YES;
}

@end
