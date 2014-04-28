//
//  StdOutView.m
//  Auger
//
//  Created by Lee Walsh on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LogView.h"


@implementation LogView

/*
-(id)init {
	NSLog(@"Init stdoutView.");
	self = [self initStdOutView];
	return self;
}
*/

-(void) writeToLog: (NSString *) logMsg  WithTimeStamp: (BOOL) timeStamp AndUpdateDisplay: (BOOL) updateDisplay{
	NSLog(@"%@",logMsg);
	
	NSDate *currentDate = [[NSDate alloc] init];
	NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
	[dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSString *datedMsg;
	if (timeStamp) {
		datedMsg = [NSString stringWithFormat:@"[%@] %@", [dateFormater stringFromDate:currentDate],logMsg];
	}
	else {
		datedMsg = [NSString stringWithFormat:@"%@",logMsg];
	}

	
	NSRange endRange;
	endRange.location = [[self textStorage] length];
	endRange.length = 0;
	[self replaceCharactersInRange: endRange withString: datedMsg];
	endRange.length = [datedMsg length];
	[self scrollRangeToVisible: endRange];
	
	[dateFormater release];
	[currentDate release];
	if(updateDisplay)
	{
		[self display];	//setNeedsDisplay: YES];
	}
}

@end
