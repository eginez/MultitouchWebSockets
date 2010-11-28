#import "WebSocketServer_Prefix.pch"

extern NSString * const kNotifcationNewClient;

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

+ (WebSocketServer *)startThreaded:(NSNumber *)port;
- (void)start:(NSNumber *)port;
- (void)sendMessage:(NSString *)message toClient:(int)clientId;
- (void)broadcastMessage:(NSString *)message;
- (void)stop;
- (void)parseHandshake:(NSString *)message;
- (BOOL)sendHandshake;
- (NSData *)frameData:(NSData *)payload;

@end
