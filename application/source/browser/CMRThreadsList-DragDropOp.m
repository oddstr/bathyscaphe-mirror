//
//  CMRThreadsList-DragDropOp.m -- 将来の再構成が容易になるように、別ファイルに切り離しておく
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/01/28.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "CMRThreadsList_p.h"

@implementation CMRThreadsList(DraggingImage)
+ (NSImage *) threadDocumentIcon
{
	return [[NSWorkspace sharedWorkspace] iconForFileType: @"thread"];
}

- (NSBezierPath *) calcRoundedRectForRect: (NSRect) bgRect
{
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 5.0;
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    return bgPath;
}

- (NSAttributedString *) attributedStringFromTitle: (NSString *) threadTitle andURL: (NSString *) urlString
{
	NSMutableDictionary		*attr_, *attr2_;
	NSMutableAttributedString	*attrStr_;
	NSAttributedString	*urlStr_;
	NSFont					*boldFont_;
	
	attr_ = [NSMutableDictionary dictionary];
	attr2_ = [NSMutableDictionary dictionary];

	boldFont_ = [NSFont boldSystemFontOfSize: [NSFont smallSystemFontSize]];

	[attr_ setObject : [NSFont labelFontOfSize: 0] forKey : NSFontAttributeName];
	[attr_ setObject : [NSColor whiteColor] forKey : NSForegroundColorAttributeName];
	[attr2_ setObject: boldFont_ forKey: NSFontAttributeName];
	[attr2_ setObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName];

	attrStr_ = [[NSMutableAttributedString alloc] initWithString: threadTitle attributes: attr2_];
	urlStr_ = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"\n%@", urlString] attributes: attr_];
	
	[attrStr_ appendAttributedString: urlStr_];
	[urlStr_ release];

	return [attrStr_ autorelease];
}

- (NSImage *) dragImageWithIconForAttributes: (NSDictionary *) attr offset: (NSPointPointer) dragImageOffset
{
	NSString	*title_ = [attr objectForKey: CMRThreadTitleKey];
	NSAttributedString	*titleAttrStr_ = [[self class] objectValueTemplate: title_ forType: kValueTemplateDefaultType];
		
	NSImage *titleImg = [[NSImage alloc] init];
	NSSize	strSize_ = [titleAttrStr_ size];
	
	[titleImg setSize: strSize_];
	[titleImg lockFocus];
	[titleAttrStr_ drawInRect: NSMakeRect(0,0,strSize_.width,strSize_.height)];
	[titleImg unlockFocus];

	NSImage	*icon_ = [[self class] threadDocumentIcon];
	[icon_ setSize : NSMakeSize(16, 16)];
	
	NSImage *finalImg = [[NSImage alloc] init];
    float dy = 0;
    float dyTitle = 0;

	float	whichHeight = [CMRPref threadsListRowHeight];
	if (whichHeight < strSize_.height) {
	   whichHeight = strSize_.height;
	} else if (whichHeight > strSize_.height) {
	   dyTitle = (whichHeight - strSize_.height)*0.5;
	}
	if (whichHeight < 16.0) {
	   whichHeight = 16.0;
	   dyTitle = (16.0 - strSize_.height)*0.5;
	} else if (whichHeight > 16.0) {
	   dy = (whichHeight - 16.0)*0.5;
	}

	NSRect	imageRect_ = NSMakeRect(0, 0, strSize_.width+19.0, whichHeight);
	[finalImg setSize: imageRect_.size];
	[finalImg lockFocus];
	[icon_ compositeToPoint: NSMakePoint(0, dy) operation: NSCompositeCopy fraction: 0.9];
	[titleImg compositeToPoint: NSMakePoint(19.0,dyTitle) operation: NSCompositeCopy fraction: 0.8];

	[finalImg unlockFocus];
	
	[titleImg release];

	dragImageOffset->x = imageRect_.size.width * 0.5 - 8.0;

	return [finalImg autorelease];
}	

- (NSImage *) dragImageWithTitleAndURLForAttributes: (NSDictionary *) attr offset: (NSPointPointer) dragImageOffset
{
	NSString		*title_;
	NSAttributedString	*attrStr_;
	NSColor			*bgColor_;
	
	NSImage	*anImg = [[NSImage alloc] init];
	NSRect	imageBounds;

	title_ = [attr objectForKey : CMRThreadTitleKey];

	attrStr_ = [self attributedStringFromTitle: title_ andURL: [[CMRThreadAttributes threadURLFromDictionary : attr] absoluteString]];

	NSSize strSize_ = [attrStr_ size];
	NSRect strRect_ = NSMakeRect(0, 0, strSize_.width+10.0, strSize_.height+10.0);

	imageBounds.origin = NSMakePoint(5.0, 5.0);
	imageBounds.size = strSize_;

	bgColor_ = [[NSColor alternateSelectedControlColor] colorWithAlphaComponent: 0.9];

	[anImg setSize : strRect_.size];

	[anImg lockFocus];
	[bgColor_ set];
	[[self calcRoundedRectForRect: strRect_] fill];
	[attrStr_ drawInRect: imageBounds];
	[anImg unlockFocus];

	dragImageOffset->x = strSize_.width * 0.5;
	dragImageOffset->y = 10.0;

	return [anImg autorelease];
}

- (void) drawStringIn : (NSRect) rect withString : (NSString *) str
{
	NSMutableDictionary		*attr_;
	NSPoint					stringOrigin;
	NSSize					stringSize;
	
	attr_ = [[NSMutableDictionary alloc] init];

	[attr_ setObject : [NSFont boldSystemFontOfSize : 12.0 ] forKey : NSFontAttributeName];
	[attr_ setObject : [NSColor whiteColor] forKey : NSForegroundColorAttributeName];

	stringSize = [str sizeWithAttributes : attr_];
	stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width) / 2;
	stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height) / 2;
	
	[str drawAtPoint : stringOrigin withAttributes : attr_];
	
	[attr_ release];
}

- (NSImage *) threadIconWithBadgeOfCount : (unsigned int) countOfRows
{
	NSImage	*anImg = [[NSImage alloc] init];
	NSRect	imageBounds;
	NSString	*str_;

	str_ = [NSString stringWithFormat : @"%i", countOfRows];

	imageBounds.origin = NSMakePoint(16.0, 15.0);
	imageBounds.size = NSMakeSize(26.0, 26.0);

	[anImg setSize : NSMakeSize(40.0, 40.0)];

	[anImg lockFocus];
	[self drawStringIn : imageBounds withString : str_];
	[[NSImage imageAppNamed : @"DraggingBadge"] compositeToPoint : NSMakePoint(16.0, 14.0)
													   operation : NSCompositeDestinationOver];
	[[[self class] threadDocumentIcon] compositeToPoint: NSMakePoint(4.0, 0.0)
											  operation: NSCompositeDestinationOver
											   fraction: 0.9];
	[anImg unlockFocus];

	return [anImg autorelease];
}

#pragma mark -
- (NSImage *) dragImageForRowIndexes: (NSIndexSet *) rowIndexes inTableView: (NSTableView *) tableView offset: (NSPointPointer) dragImageOffset
{
	unsigned int countOfRows = [rowIndexes count];

	if (countOfRows > 1) {
		return [self threadIconWithBadgeOfCount: countOfRows];
	} else {
		NSDictionary	*thread_;
		thread_ = [self threadAttributesAtRowIndex: [rowIndexes firstIndex] inTableView: tableView];
		
		if (nil == thread_) return nil;

		NSString *path_ = [CMRThreadAttributes pathFromDictionary: thread_];

		if([[NSFileManager defaultManager] fileExistsAtPath: path_]) {
			return [self dragImageWithIconForAttributes: thread_ offset: dragImageOffset];
		} else {
			return [self dragImageWithTitleAndURLForAttributes: thread_ offset: dragImageOffset];
		}
	}
	
	return nil;
}
@end
