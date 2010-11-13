#import <Foundation/Foundation.h>

extern NSString * const kNotification;
extern NSString * const kNotificationMessage;

@class AsyncSocket;

@interface WebSocketServer : NSObject {
    AsyncSocket *socket;
    BOOL isRunning;
	BOOL isHandShaken;
	NSMutableDictionary *headerInfo;
    NSNotificationCenter* notificationCenter;
}

@property (readwrite, assign) BOOL isRunning;
@property (readwrite, assign) BOOL isHandShaken;

- (void)start:(NSNumber *)port;
- (void)sendMessage:(NSString *)message;
- (void)stop;
- (void)parseHandshake:(NSString *)message

@end
