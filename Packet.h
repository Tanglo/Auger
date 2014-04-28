//
//  Packet.h
//  Auger
//
//  Created by Lee Walsh on 23/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Packet : NSObject {
	uint8_t recordType;
	uint32_t addr;
	uint8_t data[256];
	//uint8_t checksum;
	NSInteger dataCount;
	BOOL checksumValid;

}
@property uint32_t addr;
@property uint8_t recordType;	//,checksum;
@property BOOL checksumValid;
//@property NSInteger dataCount;

-(Packet *) initPacket;
-(void) eraseData;
-(void) addDataByte: (uint8_t) dataBytes;
-(uint8_t) dataByte: (NSInteger) index;
-(NSInteger) dataCount;


@end
