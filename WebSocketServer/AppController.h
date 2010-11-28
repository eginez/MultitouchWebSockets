#import "WebSocketServer_Prefix.pch"

@class AppController;
@class WebSocketServer;

@interface AppController : NSObject {
	int numClients;
    WebSocketServer *server;
}

- (void) OnNewClient:(NSNumber *)clientId;
- (void) OnClientDisconnected:(NSNumber *)clientId;
- (void) OnTouch:(NSString *)touchData;
- (void) setServer:(WebSocketServer *)ws;

@end
