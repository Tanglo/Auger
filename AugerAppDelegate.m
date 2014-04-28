//
//  AugerAppDelegate.m
//  Auger
//
//  Created by Lee Walsh on 3/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AugerAppDelegate.h"

@implementation AugerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	[augerInstance loadPreferences];

	/*
	self = [super init];
	NSLog(@"Initialising stdoutView.");
	
	stdOutPipe = [NSPipe pipe];
	stdOutHandle = [stdOutPipe fileHandleForReading];
	dup2([[stdOutPipe fileHandleForWriting] fileDescriptor], fileno(stdout));
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(stdoutRead:) name: NSFileHandleReadCompletionNotification object: stdOutHandle];
	[stdOutHandle readInBackgroundAndNotify] ;
	 */
	
}

/*
-(void) stdoutRead: (NSNotification*) notification {
	NSLog(@"Reading from stdout.");
	[stdOutHandle readInBackgroundAndNotify] ;
	NSString *stdoutString = [[NSString alloc] initWithData: [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem] encoding: NSASCIIStringEncoding];
	// Do whatever you want with str
	NSLog(@"stdout str received: %@",stdoutString);
	[OutputLog writeToLog:stdoutString];
}
*/

- (IBAction)openAboutPanel:(id)sender
{
    NSDictionary *options;
    NSImage *img;
	NSAttributedString *webURL;
	[webURL initWithString:@"www.certaintanlge.com"];
	
    img = [NSImage imageNamed: @"auger.icns"];
    options = [NSDictionary dictionaryWithObjectsAndKeys:
			   webURL,@"Credits",		//hasn't been released
			   @"v0.5", @"Version",
			   @"Auger", @"ApplicationName",
			   img, @"ApplicationIcon",
			   @"Copyright 2011, Lee David Walsh", @"Copyright",
			   @"Auger 0.5.0", @"ApplicationVersion",
			   nil];
	
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender {
	[augerInstance savePreferences];
	return NSTerminateNow;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

@end
