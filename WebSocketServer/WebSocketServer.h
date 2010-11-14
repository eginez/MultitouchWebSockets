#import <Foundation/Foundation.h>

extern NSString * const kNotification;
extern NSString * const kNotificationMessage;

@class AsyncSocket;
@class WebSocketUtilities;

@interface WebSocketServer : NSObject {
    AsyncSocket *listenersocket;
	NSMutableArray *clients;
    BOOL isRunning;
	BOOL isHandShaken;
	NSMutableDictionary *headerInfo;
    NSNotificationCenter* notificationCenter;
	WebSocketUtilities *util;
}

@property (readwrite, assign) BOOL isRunning;
@property (readwrite, assign) BOOL isHandShaken;

- (void)start:(NSNumber *)port;
- (void)sendMessage:(NSString *)message toClient:(int)clientId;
- (void)stop;
- (void)parseHandshake:(NSString *)message;
- (BOOL)sendHandshake;
- (NSData *)frameData:(NSData *)payload;

@end
