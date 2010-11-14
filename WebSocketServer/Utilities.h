/*
 *  Utilities.h
 *  WebSocketServer
 *
 *  Created by Esteban  Ginez on 10-11-13.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface WebSocketUtilities:NSObject{
}

- (NSString *)stringToHex:(NSString *)string;
- (NSUInteger)getKeyValue:(NSString *)key numberOfSpaces:(int *)spaces ;
- (NSData *)calculateChallenge:(uint32 ) num1 number2:(uint32 )num2 rand:(NSString *)rand;
@end