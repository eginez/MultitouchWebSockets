//
//  main.m
//  WebSocketServer
//
//  Created by Esteban  Ginez on 10-11-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "WebSocketServer.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    // insert code here...
    NSLog(@"Hello, World!");
    WebSocketServer *server = [[WebSocketServer alloc] init];
	NSNumber *nPort = [NSNumber numberWithInt:50000];
	
	[server performSelector:@selector(start:) withObject:nPort afterDelay:1.0];
	[[NSRunLoop currentRunLoop]run];
	[nPort release];
	[server release];
	[pool drain];
    return 0;
}
