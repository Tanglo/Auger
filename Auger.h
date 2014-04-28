//
//  Auger.h
//  Auger
//
//  Created by Lee Walsh on 3/02/11.
//  Copyright 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogView.h"
#import <termios.h>
#import <sys/ioctl.h>
//#import <poll.h>
//#import <sys/select.h>
#import "Packet.h"
//#import <unistd.h>
//#import <stdlib.h>

@interface Auger : NSObject {
	
	IBOutlet LogView *OutputLog;
	IBOutlet NSTextField *serialPortPathField;
	IBOutlet NSTextField *hexFilePathField;
	IBOutlet NSButton *runCheckBox;
	IBOutlet NSButton *debugCheckBox;
	IBOutlet NSButton *loadToZeroCheckBox;
	
	struct termios defaultSettings;
	uint8_t inBuffer[256];
	//uint8_t BACKSPACE;// = 0x08;
	//uint8_t ERASE_ALL;// = 0x00;
	//uint8_t ACK;// = 0x06;
	
	NSMutableArray *packets;
	
	NSInteger errors;
	NSInteger warnings;

}

-(Auger *) initAuger;
-(void) resetAuger;
-(IBAction) programADuC: (id) sender;
-(IBAction) eraseADuC: (id) sender;
-(int) openSerialPort: (const char *) portPath;
-(void) closeSerialPort: (int) commsPort;
-(NSInteger) writeSerial: (uint8_t *) data To: (int) commsPort With: (int) count;		//For: (int) timeout;
-(NSInteger) read: (int) count OfSerial: (uint8_t *) data From: (int) commsPort;
-(NSInteger)prepareHexFile;
-(Packet *)decodeHexLine: (NSString *) hexLine;
-(NSString *) connectToADuCVia: (int) commsPort;
-(BOOL) eraseDeviceVia: (int) commsPort;
-(BOOL) loadProgramVia: (int) commsPort;
-(BOOL) verifyProgramVia: (int) commsPort;
-(BOOL) runProgramVia: (int) commsPort;
-(void) generatePacketAt: (uint8_t *) packet To: (uint8_t) command From: (NSInteger) packetNo With: (uint32_t) addressOffset;
-(BOOL) savePreferences;
-(BOOL) loadPreferences;
-(IBAction) selectHexFile: (id) sender;
@end
