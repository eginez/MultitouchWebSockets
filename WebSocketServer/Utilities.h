/*
 *  Utilities.h
 *  WebSocketServer
 *
 *  Created by Esteban  Ginez on 10-11-13.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "WebSocketServer_Prefix.pch"

#ifdef DEBUG
#define TLog(xx, ...) NSLog(@"%s(%d): " xx, ((strrchr(__FILE__, '/') ? : __FILE__- 1) + 1), __LINE__, ##__VA_ARGS__)
#else
#define TLog(xx, ...) ((void)0)
#endif

@interface WebSocketUtilities:NSObject{
}

- (NSString *)stringToHex:(NSString *)string;
- (NSUInteger)getKeyValue:(NSString *)key numberOfSpaces:(int *)spaces ;
- (NSData *)calculateChallenge:(uint32 ) num1 number2:(uint32 )num2 rand:(NSString *)rand;
@end