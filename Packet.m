//
//  Packet.m
//  Auger
//
//  Created by Lee Walsh on 23/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Packet.h"


@implementation Packet

@synthesize addr,recordType,checksumValid;	//,checksum;	//, dataCount;

-(Packet *) initPacket {
	self = [super init];
	dataCount = 0;
	checksumValid = NO;
	return self;
}

-(void) eraseData {
	dataCount = 0;
}

-(void) addDataByte: (uint8_t) dataBytes {
	data[dataCount] = dataBytes;
	dataCount++;
}

-(uint8_t) dataByte: (NSInteger) index {
	return data[index];
}

-(NSInteger) dataCount {
	return dataCount;
}

@end
