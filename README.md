Auger
=====

A an OS X utility for loading intel .hex files onto an ADuC70xx devices.

Auger is an ADuC70xx serial downloader application for Mac OS X.  It is intended to load intel .hex files onto ADuC70xx devices from OS X.5 and above.  It's implementation is based upon the serial download protocol detailed in Analog Devices Application Note AN-724.

#####Dependancies:  
Auger has been written and tested on Mac OS X.6.  It should also work on OS X.5, but this is not tested or formally supported.

#####Installation:  
Auger is a stand alone application.  Just put it in the folder you want it and it will run.
	
#####How to use it:  
Auger will connect to the serial port specified in the serial port path box and use it to communicate with the ADuC device.  This serial port can be a virtual serial port connected to a USB port, just make sure you have the corect drivers for it to appear as a device with the path /dev/tty.*.  
Auger will program a compiled intel .hex file onto the ADuC70xx device.  Please note that while ADuC706x devices have not been tested at this stage, their is no reason that they should not work with Auger under most circumstances.

#####Functions:  
Erase ADuC 	- Pressing this will perform a mass erase of the connected ADuC70xx device.  
ProgramADuC 	- Pressing this will perform a mass erase of the connected ADuC70xx device and then program the specifed .hex file to the device.  
Run		- If this box is checked Auger will attempt to run the ADuC70xx device after completing a 'Program ADuC'.  
Debug		- If this box is checked Auger will output various debug information to the Auger log.  At this stage it is a few things that I have found useful.  If there is anything else you would like included as debug information please contact developer@certaintangle.com and I'll see what I can do.  
Load to 0x00000000 - If this button is checked Auger and the opening line of the specified .hex file is an 02 or 04 record, Auger will ignore that record.  This is to deal with the fact that hex files may be compile to load to 0x00080000, but the serial downloader treats this address as 0x00000000, i.e. the start of flash.  This box is intended as a simple work around and removes the need to delete the opening line from the .hex file.  If checking this box does not solve your problem then you should compile you .hex file to load to 0x0.  
