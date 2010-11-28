#import "AppController.h"
#import "WebSocketServer.h"
#import "Utilities.h"

@implementation AppController

- (id) init{
    if (!(self = [super init]))
        return nil;
    numClients = 0;
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(OnNewClient:) 
	 name:@"kNewClient" object:nil];
    return self;
}

- (void) dealloc{
    [super dealloc];
}

- (void) OnNewClient:(NSNumber *)clientId{
    TLog(@"new client added");
	numClients++;
}
- (void) OnClientDisconnected:(NSNumber *)clientId{
	TLog(@"new client added");
	numClients--;
}
- (void) OnTouch:(NSString *)touchData{
	TLog(@"Touch");
	if(server != nil && numClients > 0)
		//[server broadcastMessage:touchData];
		[server performSelectorOnMainThread:@selector(broadcastMessage:) withObject:touchData waitUntilDone:true];
}
- (void) setServer:(WebSocketServer *)ws{
	server = ws;
}
@end
