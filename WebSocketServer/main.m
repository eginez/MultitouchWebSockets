//
//  main.m
//  WebSocketServer
//
//  Created by Esteban  Ginez on 10-11-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#include "Multitouch.h"
#import "WebSocketServer.h"
#import "AppController.h"
#import "Utilities.h"

AppController *theApp = NULL;
int MytouchCallback(int device, Touch *data, int nFingers, double timestamp, int frame) {
	
	fprintf(stderr,"number of finger is %d\n",nFingers);
	NSMutableString *ns =[[NSMutableString alloc] initWithCapacity:nFingers];
	for(int i=0;i<nFingers;i++){
		Touch *f = &data[i];
		[ns appendFormat:@"%d %f %f",f->identifier,f->normalized.position.x*100, f->normalized.position.y*100];
	}
	TLog(@"sending data to App Controller %@",ns);
	if(theApp != NULL)
		 [theApp OnTouch:ns];
	/*
	 //if we pinch-in (zoom-in)
	 if(distAB > 0.40 && distAB < 0.41) {
	 printf("pinch-in detected\n");
	 
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)55, true); // command (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)69, true); // + (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)69, false); // + (out)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)55, false); // command (out)
	 } else if(distAB < 0.80 && distAB > 0.79) { //if we pinch-out (zoom-out)
	 printf("pinch-out detected\n");
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)55, true); // command (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)78, true); // command (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)78, false); // command (hit)
	 */
	return 0;
}

void startInputDevices(){
	NSLog(@"Initiang input");
	NSMutableArray* deviceList = (NSMutableArray*)MTDeviceCreateList(); //grab our device list
	for(int i = 0; i<[deviceList count]; i++) { //iterate available devices
		MTRegisterContactFrameCallback([deviceList objectAtIndex:i], MytouchCallback); //assign callback for device
		MTDeviceStart([deviceList objectAtIndex:i], 0); //start sending events
	}
}


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	AppController *app = [[AppController alloc] init];
	theApp = app;
	NSLog(@"Initiaing websocket server");
	WebSocketServer *server = [[WebSocketServer alloc] init];
	[app setServer:server];
	NSNumber *nPort = [NSNumber numberWithInt:50000];
	[server performSelector:@selector(start:) withObject:nPort afterDelay:1.0];
	//[NSThread detachNewThreadSelector:@selector(startThreaded:) toTarget:[WebSocketServer class] withObject:nPort];
	startInputDevices();
	[[NSRunLoop currentRunLoop] run];
	[nPort release];
	[pool drain];
    return 0;
}
