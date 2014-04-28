//
//  StdOutView.h
//  Auger
//
//  Created by Lee Walsh on 10/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LogView : NSTextView {

}

-(void) writeToLog: (NSString *) logMsg WithTimeStamp: (BOOL) timeStamp AndUpdateDisplay: (BOOL) updateDisplay;

@end
