//
//  AugerAppDelegate.h
//  Auger
//
//  Created by Lee Walsh on 3/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogView.h"
#import "Auger.h"

@interface AugerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	IBOutlet Auger *augerInstance;
	
//	IBOutlet LogView *OutputLog;
//	NSPipe *stdOutPipe;
//	NSFileHandle *stdOutHandle;
}

@property (assign) IBOutlet NSWindow *window;

//-(void) stdoutRead: (NSNotification*) notification;
- (IBAction)openAboutPanel:(id)sender;

@end
