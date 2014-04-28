//
//  Auger.m
//  Auger
//
//  Created by Lee Walsh on 3/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Auger.h"


@implementation Auger

- (void)dealloc {
    [packets release];
    [super dealloc];
}

-(id)init {
	self = [self initAuger];
	return self;
}

-(Auger *) initAuger {
	self = [super init];
	packets = [[NSMutableArray alloc] init];
	errors = 0;
	warnings = 0;
	return self;
}

-(void) resetAuger {
	errors = 0;
	warnings = 0;
	[packets removeAllObjects];
}

-(IBAction) programADuC: (id) sender {
	 
	//errors = 0;
	//warnings = 0;
	[OutputLog writeToLog: @"\n" WithTimeStamp: NO AndUpdateDisplay: NO];
	[OutputLog writeToLog: @"Programming ADUC.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
	if ([self prepareHexFile]) {
		NSString *serialPortPath = [NSString stringWithFormat:@"/dev/tty.%@",[[serialPortPathField cell] stringValue]];
		int commsPort = [self openSerialPort: [serialPortPath UTF8String]];	//"/dev/tty.PL2303-000014FA"];	//usbserial-FTEIW9XY"];	//PL2303-000014FA"];	//usbserial-A7005fdU"];
		if (commsPort >= 0) {
			[OutputLog writeToLog:[NSString stringWithFormat: @"Port opened.  Identifer: %i\n",commsPort] WithTimeStamp: YES AndUpdateDisplay: YES];
			if([self connectToADuCVia:commsPort] != nil) {
				if([self eraseDeviceVia:commsPort]) {
					[OutputLog writeToLog:@"Device memory erased.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
					if ([self loadProgramVia: commsPort]) {
						if ([self verifyProgramVia:commsPort]) {
							[OutputLog writeToLog:@"Program successfully loaded.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
							if ([runCheckBox state] == NSOnState) {
								if([self runProgramVia: commsPort]) {
									[OutputLog writeToLog:@"Run command successful.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
								}
								else {
									[OutputLog writeToLog:@"Warning: Run command not acknowledged.  Hard reset required.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
								}
							}
						}
						else {
							[OutputLog writeToLog:@"Error: load verification.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
							errors++;
						}
					}
					else {
						[OutputLog writeToLog:@"Error: program not loaded.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
						errors++;
					}
				}
				else {
					[OutputLog writeToLog:@"Error: device memory not erased.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
					errors++;
				}
			}
							
			/*int nBytesWritten = [self writeSerial: BACKSPACE To: commsPort With: sizeof(BACKSPACE)];	//For: 1000];
		//[OutputLog writeToLog:[NSString stringWithFormat: @"1. Buffer contents: %s\n",inBuffer]];
			int nBytesRead = [self read: 24 OfSerial: inBuffer From: commsPort];
			[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES];
			[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes read from serial port\n",nBytesRead] WithTimeStamp: YES];
			[OutputLog writeToLog:[NSString stringWithFormat: @"Read: \"%s\"\n",inBuffer] WithTimeStamp: YES];*/
			
			[self closeSerialPort: commsPort];
		}
	}
	else {
		[OutputLog writeToLog:[NSString stringWithFormat: @"Error: Hex file not ready."] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
	}
	[OutputLog writeToLog:[NSString stringWithFormat:@"Finished. %d Errors, %d Warnings.\n",errors,warnings] WithTimeStamp: YES AndUpdateDisplay: YES];
	[self resetAuger];
}

-(IBAction) eraseADuC: (id) sender {
	errors = 0;
	warnings = 0;
	[OutputLog writeToLog: @"\n" WithTimeStamp: NO AndUpdateDisplay: NO];
	[OutputLog writeToLog: @"Erasing ADUC.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
	NSString *serialPortPath = [NSString stringWithFormat:@"/dev/tty.%@",[[serialPortPathField cell] stringValue]];
	int commsPort = [self openSerialPort: [serialPortPath UTF8String]];	//"/dev/tty.PL2303-000014FA"];	//usbserial-FTEIW9XY"];	//PL2303-000014FA"];	//usbserial-A7005fdU"];
	if (commsPort >= 0) {
		[OutputLog writeToLog:[NSString stringWithFormat: @"Port opened.  Identifer: %i\n",commsPort] WithTimeStamp: YES AndUpdateDisplay: YES];
		if([self connectToADuCVia:commsPort] != nil) {
			if([self eraseDeviceVia:commsPort]) {
				[OutputLog writeToLog:@"Device memory erased.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
				
			}
			else {
				[OutputLog writeToLog:@"Error: device memory not erased.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
			}
		}
		
		/*int nBytesWritten = [self writeSerial: BACKSPACE To: commsPort With: sizeof(BACKSPACE)];	//For: 1000];
		 //[OutputLog writeToLog:[NSString stringWithFormat: @"1. Buffer contents: %s\n",inBuffer]];
		 int nBytesRead = [self read: 24 OfSerial: inBuffer From: commsPort];
		 [OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES];
		 [OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes read from serial port\n",nBytesRead] WithTimeStamp: YES];
		 [OutputLog writeToLog:[NSString stringWithFormat: @"Read: \"%s\"\n",inBuffer] WithTimeStamp: YES];*/
		[self closeSerialPort: commsPort];
	}
	
	[OutputLog writeToLog:[NSString stringWithFormat:@"Finished. %d Errors, %d Warnings.\n",errors,warnings] WithTimeStamp: YES AndUpdateDisplay: YES];
	[self resetAuger];
}

-(int) openSerialPort: (const char *) portPath {
	[OutputLog writeToLog:[NSString stringWithFormat: @"Opening: %s\n",portPath] WithTimeStamp: YES AndUpdateDisplay: YES];
	//	fflush(stdout);
	
	int	commsPort = -1;
    struct termios settings;
	
	// Open the serial port read/write, with no controlling terminal, and don't wait for a connection.
    // The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.
    // See open(2) ("man 2 open") for details.
	commsPort = open(portPath, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (commsPort == -1)
    {
        //printf("Error opening serial port %s - %s(%d).\n",portPath, strerror(errno), errno);
		[OutputLog writeToLog:[NSString stringWithFormat:@"Error: Can't open serial port %s - %s(%d).\n",portPath, strerror(errno), errno] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
        goto error;
    }
	
	// Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed
    // unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
    // processes.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
    
    if (ioctl(commsPort, TIOCEXCL) == -1)
    {
        //printf("Error setting TIOCEXCL on %s - %s(%d).\n",portPath, strerror(errno), errno);
		[OutputLog writeToLog:[NSString stringWithFormat:@"Error setting TIOCEXCL on %s - %s(%d).\n",portPath, strerror(errno), errno] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
        goto error;
    }
    
    // Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
    // See fcntl(2) ("man 2 fcntl") for details.
    
    if (fcntl(commsPort, F_SETFL, 0) == -1)
    {
        //printf("Error clearing O_NONBLOCK %s - %s(%d).\n",portPath, strerror(errno), errno);
		[OutputLog writeToLog:[NSString stringWithFormat:@"Error clearing O_NONBLOCK %s - %s(%d).\n",portPath, strerror(errno), errno] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
        goto error;
    }
	
	// Get the current options and save them so we can restore the default settings later.
    if (tcgetattr(commsPort, &defaultSettings) == -1)
    {
        //printf("Error getting tty attributes %s - %s(%d).\n",portPath, strerror(errno), errno);
		[OutputLog writeToLog:[NSString stringWithFormat:@"Error getting tty attributes %s - %s(%d).\n",portPath, strerror(errno), errno] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
        goto error;
    }
	
	//set attributes (based on what Phil did)
	settings.c_lflag    &= ~(ECHO | ICANON | IEXTEN | ISIG);
    settings.c_iflag    &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    settings.c_oflag    &= ~(OPOST);
    settings.c_cflag    &= ~( CRTSCTS | HUPCL);
    settings.c_cflag    |= CS8 | CLOCAL;
    settings.c_cc[VMIN]  = 0;
    settings.c_cc[VTIME] = 0;
	
	//set baud rate
	cfsetispeed(&settings, B38400);	
	cfsetospeed(&settings, B38400);
	
	// Apply the new settings
    if (tcsetattr(commsPort, TCSANOW, &settings) == -1)
    {
        //printf("Error setting tty attributes %s - %s(%d).\n",portPath, strerror(errno), errno);
		[OutputLog writeToLog:[NSString stringWithFormat:@"Error: Can't set tty attributes %s - %s(%d).\n",portPath, strerror(errno), errno] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
        goto error;
    }
	
	return commsPort;
	
error:
    if (commsPort != -1)
    {
        close(commsPort);
    }
    
    return -1;
}

-(void) closeSerialPort: (int) commsPort {
    // Block until all written output has been sent from the device.
    // Note that this call is simply passed on to the serial device driver. 
	// See tcsendbreak(3) ("man 3 tcsendbreak") for details.
    if (tcdrain(commsPort) == -1)
    {
        //printf("Error waiting for drain - %s(%d).\n", strerror(errno), errno);
		[OutputLog writeToLog:[NSString stringWithFormat: @"Error: Serial port not drained - %s(%d).\n", strerror(errno), errno] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
    }
    
    // Traditionally it is good practice to reset a serial port back to
    // the state in which you found it. This is why the original termios struct
    // was saved.
    if (tcsetattr(commsPort, TCSANOW, &defaultSettings) == -1)
    {
        //printf("Error resetting tty attributes - %s(%d).\n",strerror(errno), errno);
		[OutputLog writeToLog:[NSString stringWithFormat: @"Error: Can't reset tty attributes - %s(%d).\n",strerror(errno), errno] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
    }
	//tcflush(commsPort, TCIOFLUSH);		//does not solve repeated 'Program ADuC' ID error.
    close(commsPort);
}

-(NSInteger) writeSerial: (uint8_t *) data To: (int) commsPort With: (int) count {	//For: (int) timeout {	
	int nfds = 0,ready,len;
	const uint8_t *ptr = data;
	fd_set rd,wr,er;
	nfds = commsPort;	//max(nfds,commsPort);
	FD_ZERO(&rd);
	FD_ZERO(&wr);
	FD_ZERO(&er);
	FD_SET(commsPort,&wr);
	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	
	if ([debugCheckBox state] == NSOnState) {
		//print data to log
		[OutputLog writeToLog:@"Data to write to serial port: " WithTimeStamp: YES AndUpdateDisplay: NO];
		for(int i=0 ; i<count ; i++) {
			[OutputLog writeToLog:[NSString stringWithFormat: @"%.2X", data[i]] WithTimeStamp: NO AndUpdateDisplay: NO];
		}
		[OutputLog writeToLog:@"\n" WithTimeStamp: NO AndUpdateDisplay: YES];
	}
	
	while(count > 0) {
		ready = select(nfds+1, &rd, &wr, &er, &timeout);
	//	[OutputLog writeToLog:[NSString stringWithFormat: @"fd ready: %d\n", ready]];
		if (FD_ISSET(commsPort,&wr) && ready) {
			//[OutputLog writeToLog:[NSString stringWithFormat: @"Serial port ready to write.\n"]];
			len = write(commsPort, ptr, count);
			if (len < 0) 
			{
				//fprintf(stderr, "writeSerial: write failed %s\n", strerror(errno));
				[OutputLog writeToLog:[NSString stringWithFormat: @"Error: Writing to serial port failed. %s\n", strerror(errno)] WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
				return -1;
			}
			ptr += len;
			count -= len;
		}
		else if (ready == 0){
			[OutputLog writeToLog:[NSString stringWithFormat: @"Error: Timeout on write.\n"] WithTimeStamp: YES AndUpdateDisplay: YES];
			errors++;
			break;
		}
	}
	
	return (NSInteger)(ptr - data);
}

-(NSInteger) read: (int) count OfSerial: (uint8_t *) data From: (int) commsPort {
	int nfds = 0,ready = 0,len;
	uint8_t *ptr = data;
	fd_set rd,wr,er;
	nfds = commsPort;	//max(nfds,commsPort);
	struct timeval timeout;
	timeout.tv_sec = 5;
	timeout.tv_usec = 0;
	FD_ZERO(&rd);
	FD_ZERO(&wr);
	FD_ZERO(&er);
	FD_SET(commsPort,&rd);
	
	// clear the data buffer
    for(int x=0;x<count;x++)
    {
    	*ptr = 0;
    	ptr++;
    }
    ptr = data;
	
	data[count] = '\0';
	while(count > 0) {
		ready = select(nfds+1, &rd, &wr, &er, &timeout);
		//[OutputLog writeToLog:[NSString stringWithFormat: @"fd ready: %d\n", ready]];
		if (FD_ISSET(commsPort,&rd) && ready) {
			//[OutputLog writeToLog:[NSString stringWithFormat: @"Serial port ready to read.\n"]];
			len = read(commsPort, ptr, count);
			if (len < 0) 
			{
				//fprintf(stderr, "writeSerial: write failed %s\n", strerror(errno));
				[OutputLog writeToLog:[NSString stringWithFormat: @"Error: Reading from serial port failed. %s\n", strerror(errno)] WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
				return -1;
			}
			ptr += len;
			count -= len;
		}
		else if (ready == 0){
			[OutputLog writeToLog:[NSString stringWithFormat: @"Error: Timeout on read.\n"] WithTimeStamp: YES AndUpdateDisplay: YES];
			errors++;
			break;
		}
	}
	return (NSInteger)(ptr - data);
}

-(NSInteger)prepareHexFile {
	NSString *hexFilePath = [[hexFilePathField cell] stringValue];	//[NSString stringWithFormat:@"%@/Documents/Work/ADuC/Blinky/flashingTest.hex",NSHomeDirectory()];
	NSStringEncoding encoding;
	NSError *error;
	NSString *hexFileString = [[NSString alloc] initWithContentsOfFile:hexFilePath usedEncoding:&encoding error:&error];  //need to release!
	if (hexFileString != nil) {
		NSScanner *hexFileScanner = [NSScanner scannerWithString:hexFileString];
		NSCharacterSet *newLineSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
		NSString *hexLine;
		
		int i=0;
		while ([hexFileScanner isAtEnd] == NO) {
			if([hexFileScanner scanString:@":" intoString:NULL] &&
			   [hexFileScanner scanUpToCharactersFromSet:newLineSet intoString:&hexLine])			//gets to next line and ignores any comments after ]
			{
				[packets addObject:[self decodeHexLine:hexLine]];
				if (![[packets objectAtIndex:[packets count]-1] checksumValid]) {
					[OutputLog writeToLog:[NSString stringWithFormat:@"2. Warning: hex file line %d checksum is not valid.\n",i] WithTimeStamp: YES AndUpdateDisplay: YES];
					warnings++;
				}
			}
			else {
				[OutputLog writeToLog:[NSString stringWithFormat:@"Error: missing colon in line %d of hex file\n",i+1] WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
				break;
			}

			i++;
		}
	}
	else {
		[OutputLog writeToLog:[NSString stringWithFormat:@"Error: Can't open hex file at %@\n%@", hexFilePath, [error localizedFailureReason]] WithTimeStamp: YES AndUpdateDisplay: YES];
	}
	[hexFileString release];
	return 1;
}

-(Packet *)decodeHexLine: (NSString *) hexLine {
	Packet *newPacket = [[Packet alloc] initPacket];
	NSString *currentByte;
	NSRange target;
	target.location = 0;
	target.length = 2;
	uint8_t byteCount;
	uint8_t checksum;
	NSScanner *hexCharScanner;
	unsigned hexData;
	
	//get the byte count
	currentByte = [hexLine substringWithRange:target];
	hexCharScanner = [NSScanner scannerWithString:currentByte];
	[hexCharScanner scanHexInt:&hexData];
	byteCount = (uint8_t)hexData;
	
	//get the address
	target.location = 2;
	target.length = 4;
	currentByte = [hexLine substringWithRange:target];
	hexCharScanner = [NSScanner scannerWithString:currentByte];
	[hexCharScanner scanHexInt:&hexData];
	[newPacket setAddr:(uint32_t)hexData];
	
	//get the record type
	target.location = 6;
	target.length = 2;
	currentByte = [hexLine substringWithRange:target];
	hexCharScanner = [NSScanner scannerWithString:currentByte];
	[hexCharScanner scanHexInt:&hexData];
	[newPacket setRecordType:(uint8_t)hexData];
	
	//get the data bytes
	target.location = 8;
	for(int i=0 ; i< (int)byteCount ; i++) {
		currentByte = [hexLine substringWithRange:target];
		hexCharScanner = [NSScanner scannerWithString:currentByte];
		[hexCharScanner scanHexInt:&hexData];
		[newPacket addDataByte:(uint8_t)hexData];
		target.location += 2;
	}
	
	//get the checksum
	currentByte = [hexLine substringWithRange:target];
	hexCharScanner = [NSScanner scannerWithString:currentByte];
	[hexCharScanner scanHexInt:&hexData];
	checksum = (uint8_t)hexData;
	
	//calculate and compare checksum
	uint8_t LSBAddress = [newPacket addr] & 0xFF;
	uint8_t MSBAddress = [newPacket addr] >> 8;
	uint8_t sum = 0;
	sum += byteCount;
	sum += LSBAddress;
	sum += MSBAddress;
	sum += [newPacket recordType];
	for(int i=0 ; i<byteCount ; i++) {
		sum += [newPacket dataByte:i];
	}
	sum ^= 0xFF;
	sum += 1;
	if (sum == checksum) {
		[newPacket setChecksumValid: YES];
	}
	
	//print record
	/*
	[OutputLog writeToLog:[NSString stringWithFormat:@"Byte count: %.2X, Address: %.4X, Record Type %.2X, Data:",byteCount,[newPacket addr],[newPacket recordType]] WithTimeStamp: YES];
	for(int i=0 ; i< (int)byteCount ; i++) {
		[OutputLog writeToLog:[NSString stringWithFormat:@"%.2X",[newPacket dataByte:i]] WithTimeStamp: NO];
	}
	[OutputLog writeToLog:[NSString stringWithFormat:@", Checksum: %.2X",checksum] WithTimeStamp: NO];
	if ([newPacket checksumValid]) {
		[OutputLog writeToLog:@" - Valid.\n" WithTimeStamp: NO];
	}
	else {
		[OutputLog writeToLog:@" - InValid.\n" WithTimeStamp: NO];
	}
	*/

	return newPacket;
}

-(NSString *) connectToADuCVia: (int) commsPort {
	uint8_t BACKSPACE[] = {0x08};
	
	int nBytesWritten = [self writeSerial: BACKSPACE To: commsPort With: sizeof(BACKSPACE)];	//For: 1000];
	int nBytesRead = [self read: 24 OfSerial: inBuffer From: commsPort];
	NSString *IDString = [NSString stringWithFormat:@"%s",inBuffer];
	
	if ([debugCheckBox state] == NSOnState) {
		[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES AndUpdateDisplay: YES];
		[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes read from serial port\n",nBytesRead] WithTimeStamp: YES AndUpdateDisplay: YES];
		//[OutputLog writeToLog:[NSString stringWithFormat: @"Read: \"%@\"\n",IDString] WithTimeStamp: YES];								//use a buffer that is not global?
	}
	if (nBytesRead == 24) {
		NSRange IDLoc;
		IDLoc.location = 0;
		IDLoc.length = 7;
		NSString *device = [IDString substringWithRange:IDLoc];
		IDLoc.length = 22;
		IDString = [IDString substringWithRange:IDLoc];		//remove \n and \r from IDString
		if ([device compare:@"ADuC702"]==NSOrderedSame) {
			[OutputLog writeToLog:[NSString stringWithFormat:@"Device found.  ID: %@\n",IDString] WithTimeStamp: YES AndUpdateDisplay: YES];
			return IDString;
		}
		else if ([device compare:@"ADuC706"]==NSOrderedSame) {
			[OutputLog writeToLog:[NSString stringWithFormat:@"Warning: ADuC706x devices are not formally supported@\n",IDString] WithTimeStamp: YES AndUpdateDisplay: YES];
			warnings++;
			return IDString;
		}
		else {
			[OutputLog writeToLog:[NSString stringWithFormat:@"Error: Invalid ID string received.  ID: %@\n",IDString] WithTimeStamp: YES AndUpdateDisplay: YES];
			errors++;
			return nil;
		}

	}
	else {
		[OutputLog writeToLog:@"Error: ID string not received from ADuC.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
		return nil;
	}
	
	return nil;
}
	
-(BOOL) eraseDeviceVia: (int) commsPort {
	uint8_t *packet = NULL;
	uint8_t ACK = 0x06;
	
	if ((packet = malloc(10 * sizeof(uint8_t))) == NULL) {
		[OutputLog writeToLog:@"Error: Can't allocate memory.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
		return NO;
	}
	[self generatePacketAt:packet To:0x45 From:-1 With:0x00000000];
	
	//print packet contents to log
	/*
	[OutputLog writeToLog:@"Data packet: " WithTimeStamp: YES];
	for(int i=0 ; i < 10 ; i++) {
		[OutputLog writeToLog:[NSString stringWithFormat:@"%.2X",packet[i]] WithTimeStamp: NO];
	}
	[OutputLog writeToLog:@"\n" WithTimeStamp: NO];
	 */
	
	//transmit packet
	NSInteger nBytesWritten = [self writeSerial:packet To:commsPort With:10];
	NSInteger nBytesRead = [self read:1 OfSerial:inBuffer From:commsPort];
	if (inBuffer[0] == ACK && nBytesRead == 1) {
		free(packet);
		packet = NULL;
		return YES;
	}
	
	if ([debugCheckBox state] == NSOnState) {
		[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES AndUpdateDisplay: NO];
		[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes read from serial port\n",nBytesRead] WithTimeStamp: YES AndUpdateDisplay: YES];
		//[OutputLog writeToLog:[NSString stringWithFormat: @"Read: \"%@\"\n",IDString] WithTimeStamp: YES];								//use a buffer that is not global?
	}
	
	free(packet);
	packet = NULL;
	return NO;
}
	
-(BOOL) loadProgramVia: (int) commsPort {
	uint8_t *packet = NULL;
	uint8_t ACK = 0x06;
	NSInteger numHexLines = [packets count];
	uint32_t addressOffset = 0x00000000;
	
	for (int i=0 ; i<numHexLines ; i++) {
		if ([[packets objectAtIndex:i] recordType] == 0x00) {
			int packetLen = [[packets objectAtIndex:i] dataCount]+9;
			free(packet);
			if ((packet = malloc(packetLen * sizeof(uint8_t))) == NULL) {
				[OutputLog writeToLog:@"Error: Can't allocate memory.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
				return NO;
			}
			[self generatePacketAt:packet To:0x57 From:i With:addressOffset];
			
			/*
			//print packet contents to log
			[OutputLog writeToLog:@"Data packet: " WithTimeStamp: YES];
			for(int i=0 ; i < packetLen ; i++) {
				[OutputLog writeToLog:[NSString stringWithFormat:@"%.2X",packet[i]] WithTimeStamp: NO];
			}
			[OutputLog writeToLog:@"\n" WithTimeStamp: NO];
			 */
			
			//transmit packet
			NSInteger nBytesWritten = [self writeSerial:packet To:commsPort With:packetLen];
			NSInteger nBytesRead = [self read:1 OfSerial:inBuffer From:commsPort];
			
			if ([debugCheckBox state] == NSOnState) {
				[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES AndUpdateDisplay: NO];
				[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes read from serial port\n",nBytesRead] WithTimeStamp: YES AndUpdateDisplay: YES];
				//[OutputLog writeToLog:[NSString stringWithFormat: @"Read: \"%@\"\n",IDString] WithTimeStamp: YES];								//use a buffer that is not global?
			}
			
			//[OutputLog writeToLog:[NSString stringWithFormat:@"Character read: %.2X\n",inBuffer[0]] WithTimeStamp: YES];
			if (!(inBuffer[0] == ACK && nBytesRead == 1)) {
				//free(packet);
				//packet == NULL;
				//return YES;
			//}
			//else {		//Error condition.  Line is was not transmitted.  Retry this line or restart entire load process?
				[OutputLog writeToLog:[NSString stringWithFormat:@"Error: Line %d not acknowledged.\n",i] WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
				free(packet);
				packet = NULL;
				return NO;
			}

		}
		else if ([[packets objectAtIndex:i] recordType] == 0x02 && ![loadToZeroCheckBox state]) {
			addressOffset = [[packets objectAtIndex:i] dataByte:0] << 8;
			addressOffset |= [[packets objectAtIndex:i] dataByte:1];
			addressOffset = addressOffset << 4;
			//[OutputLog writeToLog:[NSString stringWithFormat:@"New address offset is: %.8X\n",addressOffset] WithTimeStamp: YES];
		}
		else if ([[packets objectAtIndex:i] recordType] == 0x04 && ![loadToZeroCheckBox state]) {
			addressOffset = [[packets objectAtIndex:i] dataByte:0] << 8;
			addressOffset |= [[packets objectAtIndex:i] dataByte:1];
			addressOffset = addressOffset << 16;
			//[OutputLog writeToLog:[NSString stringWithFormat:@"New address offset is: %.8X\n",addressOffset] WithTimeStamp: YES];
		}
		else if ([[packets objectAtIndex:i] recordType] == 0x01);	//nothing to do here, its the end of the file though so if i != numHexLines-1 then a problem?
		else if ([[packets objectAtIndex:i] recordType] == 0x03) {
			[OutputLog writeToLog:@"Intel hex record type 0x03 not implemented.  Only vaild for 80x86 processors?\n" WithTimeStamp: YES AndUpdateDisplay: YES];
		}
		else if ([[packets objectAtIndex:i] recordType] == 0x05) {
			[OutputLog writeToLog:@"Intel hex record type 0x05 not implemented.  Only vaild for 80x86 processors?\n" WithTimeStamp: YES AndUpdateDisplay: YES];
		}
		else {
			[OutputLog writeToLog:@"Warning: unrecognised record type in hex file, line not programed to device.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
			warnings++;
		}
	}
	
	free(packet);
	packet = NULL;
	return YES;
}

-(BOOL) verifyProgramVia: (int) commsPort {
	uint8_t *packet = NULL;
	uint8_t ACK = 0x06;
	NSInteger numHexLines = [packets count];
	uint32_t addressOffset = 0x00000000;
	
	for (int i=0 ; i<numHexLines ; i++) {
		if ([[packets objectAtIndex:i] recordType] == 0x00) {
			int packetLen = [[packets objectAtIndex:i] dataCount]+9;
			free(packet);
			if ((packet = malloc(packetLen * sizeof(uint8_t))) == NULL) {
				[OutputLog writeToLog:@"Error: Can't allocate memory.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
				return NO;
			}
			[self generatePacketAt:packet To:0x56 From:i With:addressOffset];
			
			/*
			//print packet contents to log
			[OutputLog writeToLog:@"Data packet: " WithTimeStamp: YES];
			for(int i=0 ; i < packetLen ; i++) {
				[OutputLog writeToLog:[NSString stringWithFormat:@"%.2X",packet[i]] WithTimeStamp: NO];
			}
			[OutputLog writeToLog:@"\n" WithTimeStamp: NO];
			 */
			
			//transmit packet
			NSInteger nBytesWritten = [self writeSerial:packet To:commsPort With:packetLen];
			NSInteger nBytesRead = [self read:1 OfSerial:inBuffer From:commsPort];
			
			if ([debugCheckBox state] == NSOnState) {
				[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES AndUpdateDisplay: NO];
				[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes read from serial port\n",nBytesRead] WithTimeStamp: YES AndUpdateDisplay: YES];
				//[OutputLog writeToLog:[NSString stringWithFormat: @"Read: \"%@\"\n",IDString] WithTimeStamp: YES];								//use a buffer that is not global?
			}
			
			//[OutputLog writeToLog:[NSString stringWithFormat:@"Character read: %.2X\n",inBuffer[0]] WithTimeStamp: YES];
			if (!(inBuffer[0] == ACK && nBytesRead == 1)) {
				//free(packet);
				//packet == NULL;
				//return YES;
				//}
				//else {		//Error condition.  Line is was not verified restart, load program again?
				[OutputLog writeToLog:[NSString stringWithFormat:@"Error: Line %d not verified.\n",i] WithTimeStamp: YES AndUpdateDisplay: YES];
				errors++;
				free(packet);
				packet = NULL;
				return NO;
			}
			
		}
		else if ([[packets objectAtIndex:i] recordType] == 0x02) {
			addressOffset = [[packets objectAtIndex:i] dataByte:0] << 8;
			addressOffset |= [[packets objectAtIndex:i] dataByte:1];
			addressOffset = addressOffset << 4;
			//[OutputLog writeToLog:[NSString stringWithFormat:@"New address offset is: %.8X\n",addressOffset] WithTimeStamp: YES];
		}
		else if ([[packets objectAtIndex:i] recordType] == 0x04) {
			addressOffset = [[packets objectAtIndex:i] dataByte:0] << 8;
			addressOffset |= [[packets objectAtIndex:i] dataByte:1];
			addressOffset = addressOffset << 16;
			//[OutputLog writeToLog:[NSString stringWithFormat:@"New address offset is: %.8X\n",addressOffset] WithTimeStamp: YES];
		}
		
		//these cases not needed for verificaiton.  THey are already idenfied and noted by the loadProgramVia: method.
		/*
		else if ([[packets objectAtIndex:i] recordType] == 0x01);	//nothing to do here, its the end of the file though so if i != numHexLines-1 then a problem?
		else if ([[packets objectAtIndex:i] recordType] == 0x03) {
			[OutputLog writeToLog:@"Intel hex record type 0x03 not implemented.  Only vaild for 80x86 processors?\n" WithTimeStamp: YES];
		}
		else if ([[packets objectAtIndex:i] recordType] == 0x05) {
			[OutputLog writeToLog:@"Intel hex record type 0x05 not implemented.  Only vaild for 80x86 processors?\n" WithTimeStamp: YES];
		}
		else {
			[OutputLog writeToLog:@"Warning: unrecognised record type in hex file, line not programed to device.\n" WithTimeStamp: YES];
			warnings++;
		}
		 */
	}
	
	free(packet);
	packet = NULL;
	return YES;
}

-(BOOL) runProgramVia: (int) commsPort {
	//[OutputLog writeToLog:@"Sending run command.\n" WithTimeStamp: YES];
	//usleep(1000000);
	uint8_t *packet = NULL;
	uint8_t ACK = 0x06;
	
	if ((packet = malloc(9 * sizeof(uint8_t))) == NULL) {
		[OutputLog writeToLog:@"Error: Can't allocate memory.\n" WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
		return NO;
	}
	[self generatePacketAt:packet To:0x52 From:-1 With:0x00000000];
	
	/*
	//print packet contents to log
	[OutputLog writeToLog:@"Data packet: " WithTimeStamp: YES];
	for(int i=0 ; i < 9 ; i++) {
		[OutputLog writeToLog:[NSString stringWithFormat:@"%.2X",packet[i]] WithTimeStamp: NO];
	}
	[OutputLog writeToLog:@"\n" WithTimeStamp: NO];
	*/
	
	//transmit packet
	NSInteger nBytesWritten = [self writeSerial:packet To:commsPort With:9];
	NSInteger nBytesRead = [self read:1 OfSerial:inBuffer From:commsPort];  //seem to need to wait for ACK transmission to complete before in order for run command to work.  Reading the ACK or waiting 10000 us both work
	//usleep(10000);		
	//[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES];
	if (inBuffer[0] == ACK && nBytesRead == 1) {
		free(packet);
		packet = NULL;
		return YES;
	}
	
	if ([debugCheckBox state] == NSOnState) {
		[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes written to serial port\n",nBytesWritten] WithTimeStamp: YES AndUpdateDisplay: NO];
		[OutputLog writeToLog:[NSString stringWithFormat: @"%i of bytes read from serial port\n",nBytesRead] WithTimeStamp: YES AndUpdateDisplay: YES];
		//[OutputLog writeToLog:[NSString stringWithFormat: @"Read: \"%@\"\n",IDString] WithTimeStamp: YES];								//use a buffer that is not global?
	}
	
	free(packet);
	packet = NULL;
	return NO;
}

-(void) generatePacketAt: (uint8_t *) packet To: (uint8_t) command From: (NSInteger) packetNo  With: (uint32_t) addressOffset {
	uint8_t checksum = 0x00;
	
	packet[0] = 0x07;	//constant for all packets
	packet[1] = 0x0E;
	if (command == 0x57 && packetNo >= 0) {
		NSInteger dataCount = [[packets objectAtIndex:packetNo] dataCount];
		//[OutputLog writeToLog:[NSString stringWithFormat:@"Num data bytes: %.2X\n",dataCount] WithTimeStamp: YES];
		
		packet[2] = 0x05 + (uint8_t)dataCount;	//data byte count
		packet[3] = 0x57;	//command
		uint32_t address = addressOffset + [[packets objectAtIndex:packetNo] addr];
		for(int i=4 ; i<8 ; i++) {		//address
			packet[i] = (0xFF000000 & address) >> 24;
			address = address << 8;
		}
		for(int i=0 ; i<dataCount ; i++) {		//data bytes 6+
			packet[8+i] = [[packets objectAtIndex:packetNo] dataByte:i];
		}
		for(int i=2 ; i<dataCount+8 ; i++) {	//calculate checksum
			checksum += packet[i];
		}
		checksum = 0x00 - checksum;
		packet[dataCount+8] = checksum;
	}
	else if (command == 0x56 && packetNo >= 0) {
		NSInteger dataCount = [[packets objectAtIndex:packetNo] dataCount];
		uint8_t shifter;
		//[OutputLog writeToLog:[NSString stringWithFormat:@"Num data bytes: %.2X\n",dataCount] WithTimeStamp: YES];
		
		packet[2] = 0x05 + (uint8_t)dataCount;	//data byte count
		packet[3] = 0x56;	//command
		uint32_t address = addressOffset + [[packets objectAtIndex:packetNo] addr];
		for(int i=4 ; i<8 ; i++) {		//address
			packet[i] = (0xFF000000 & address) >> 24;
			address = address << 8;
		}
		for(int i=0 ; i<dataCount ; i++) {		//data bytes 6+.  Need to mix them around for verificiation packets
			shifter = [[packets objectAtIndex:packetNo] dataByte:i];
			packet[8+i] = (shifter & 0x1F) << 3;	//shift LS 5-bits up
			shifter = shifter >> 5;					//shift MS 3-bits down
			packet[8+i] |= shifter;			
		}
		for(int i=2 ; i<dataCount+8 ; i++) {	//calculate checksum
			checksum += packet[i];
		}
		checksum = 0x00 - checksum;
		packet[dataCount+8] = checksum;
	}
	else if (command == 0x45 && packetNo == -1 && addressOffset == 0x00000000) {
		packet[2] = 0x06;
		packet[3] = 0x45;
		for(int i=4 ; i<9 ;i++) {	//address and data = 0 -> mass erase
			packet[i] = 0x00;
		}
		for(int i=2 ; i<1+8 ; i++) {
			checksum -= packet[i];
		}
		packet[9] = checksum;
	}
	else if (command == 0x52 && packetNo == -1 && addressOffset == 0x00000000) {
		packet[2] = 0x05;
		packet[3] = 0x52;
		for(int i=4 ; i<7 ;i++) {	//address and data = 0 -> mass erase
			packet[i] = 0x00;
		}
		packet[7] = 0x01;
		packet[8] = 0xA8;	//checksum
	}
}

-(BOOL) savePreferences {
	NSLog(@"Saving preferences.");
	NSString *prefsFile = [NSString stringWithFormat:@"%@/Library/Preferences/com.certaintangle.auger.txt",NSHomeDirectory()];
	NSString *string = [NSString stringWithFormat:@"Serial port: %@\nHex file path: %@\nRun: %d\nDebug: %d\nLoad to 0x0 %d",[[serialPortPathField cell] stringValue], [[hexFilePathField cell] stringValue],[runCheckBox state],[debugCheckBox state],[loadToZeroCheckBox state]];
	NSError *error;
	BOOL ok = [string writeToFile:prefsFile atomically:YES encoding:NSUnicodeStringEncoding error:&error];
	if (!ok) {
		// an error occurred
		NSLog(@"Error writing file at %@\n%@", prefsFile, [error localizedFailureReason]);
		//NSBeep();
		return NO;
		// implementation continues ...
	}
	return YES;
}

-(BOOL) loadPreferences {
	NSString *prefsFile = [NSString stringWithFormat:@"%@/Library/Preferences/com.certaintangle.auger.txt",NSHomeDirectory()];
	NSStringEncoding encoding;
	NSError *error;
	NSString *prefString = [[NSString alloc] initWithContentsOfFile:prefsFile usedEncoding:&encoding error:&error];
	if (prefString != nil) {
		//a
	}
	else {
		[OutputLog writeToLog:[NSString stringWithFormat:@"Error: Could not open preferences file from %@\n",prefsFile] WithTimeStamp: YES AndUpdateDisplay: YES];
		errors++;
		[prefString release];
		return NO;
	}
	
	NSScanner *prefScanner = [NSScanner scannerWithString:prefString];
	NSCharacterSet *newLineSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
	NSString *serialPort;
	NSString *hexFilePath;
	NSInteger runValue,debugValue,loadValue;
	if ([prefScanner scanString:@"Serial port: " intoString:NULL] &&
		[prefScanner scanUpToCharactersFromSet:newLineSet intoString:&serialPort]) {
		[[serialPortPathField cell] setStringValue:serialPort];
	}
	if ([prefScanner scanString:@"Hex file path: " intoString:NULL] &&
		[prefScanner scanUpToCharactersFromSet:newLineSet intoString:&hexFilePath]) {
		[[hexFilePathField cell] setStringValue:hexFilePath];
	}
	if ([prefScanner scanString:@"Run: " intoString:NULL] &&
		[prefScanner scanInteger:&runValue]) {
		[runCheckBox setState:runValue];
	}
	if ([prefScanner scanString:@"Debug: " intoString:NULL] &&
		[prefScanner scanInteger:&debugValue]) {
		[debugCheckBox setState:debugValue];
	}
	if ([prefScanner scanString:@"Load to 0x0 " intoString:NULL] &&
		[prefScanner scanInteger:&loadValue]) {
		[loadToZeroCheckBox setState:loadValue];
	}
	[prefString release];
	return YES;
}

-(IBAction) selectHexFile: (id) sender {
    NSArray *fileTypes = [NSArray arrayWithObject:@"hex"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	NSString *path = [[hexFilePathField	cell] stringValue];
	if (path == nil) {
		path = NSHomeDirectory();
	}
	
	
    [oPanel setAllowsMultipleSelection:NO];
    NSInteger result = [oPanel runModalForDirectory:path file:nil types:fileTypes];
    if (result == NSOKButton) {
        NSArray *filesToOpen = [oPanel filenames];
		[[hexFilePathField cell] setStringValue: [filesToOpen objectAtIndex:0]];
	}
}

@end
