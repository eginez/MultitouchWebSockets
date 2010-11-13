
#import "WebSocketServer.h"
#import "AsyncSocket.h"


NSString * const kNotification = @"kNotification";
NSString * const kNotificationMessage = @"kNotificationMessage";

@implementation WebSocketServer

@synthesize isRunning;
@synthesize isHandShaken;

- (id) init {
    if (!(self = [super init]))
        return nil;
	
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    [self setIsRunning:NO];
    [self setIsHandShaken:NO];
    headerInfo = [[NSMutableDictionary alloc] init];
    //notificationCenter = [NSNotificationCenter defaultCenter];
    [socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	
    return self;
}

- (void)start:(NSNumber *)nport {
    int port = [nport intValue];
	if (![self isRunning]) {
        if (port < 0 || port > 65535)
			port = 0;
		
        NSError *error = nil;
		if (![socket acceptOnPort:port error:&error]){
			NSLog(@"Error listening to %@",error);
			return;
		}
		
        [self setIsRunning:YES];
    } else {
        [socket disconnect];
        [self setIsRunning:false];
    }
}

- (void)stop {
    [socket disconnect];
}

- (void)dealloc {
    [super dealloc];
    [socket disconnect];
    [socket dealloc];
	[headerInfo release];
}

- (void)sendMessage:(NSString *)message {
    NSString *terminatedMessage = [message stringByAppendingString:@"\r\n"];
    NSData *terminatedMessageData = [terminatedMessage dataUsingEncoding:NSASCIIStringEncoding];
    [socket writeData:terminatedMessageData withTimeout:-1 tag:0];
}

- (void)parseHandshake:(NSString *)message{
	NSRange foundColon;
	NSArray *pieces = [message componentsSeparatedByString:@"\r\n"];
	for(int i =0; i < [pieces count];i++)
	/*foundColon = [message rangeOfString: @":"];
    
	if(foundColon.location != NSNotFound && [headerInfo count] < 6){
        NSArray *pieces = [message componentsSeparatedByString:@": "];
		assert([pieces count] == 2);
		[headerInfo setValue:[pieces objectAtIndex:1] forKey:[pieces objectAtIndex:0]];
		//NSString *str1 = [pieces objectAtIndex:0];
		//NSString *str2 = [pieces objectAtIndex:1];
		//NSLog(@"k=%@ v=%@",str1,str2);
    }else{
		[headerInfo setValue:truncatedData forKey:@"rand"];
	}*/
	
    //Don't parse anything, just put everything in a dictionary
}

#pragma mark AsyncSocket Delegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"New client connected  %@:%hu", host, port);
    //[sock readDataToLength:255 withTimeout:0.1 tag:0];
	//[sock readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:0];
	[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSData *truncatedData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
    NSString *message = [[[NSString alloc] initWithData:truncatedData encoding:NSASCIIStringEncoding] autorelease];
	//NSString *message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
    if (message){
        NSLog(@"%@", message);
        if(!isHandShaken){
            [self parseHandshake:message];
        }else{
            NSLog(@"Incoming data from webclient");
        }
    }
    else
        NSLog(@"Error converting received data into UTF-8 String");
	
    //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:kNotificationMessage];
    //[notificationCenter postNotificationName:kNotification object:self userInfo:userInfo];
	
	[sock readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
}


@end
