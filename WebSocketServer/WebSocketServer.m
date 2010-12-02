
#import "WebSocketServer.h"
#import "AsyncSocket.h"
#import "Utilities.h"
	

NSString * const kNotificationNewClient =@"kNewClient";

@implementation WebSocketServer

@synthesize isRunning;
@synthesize isHandShaken;





- (id) init {
    if (!(self = [super init]))
        return nil;
	
    util =[WebSocketUtilities alloc];
	listenersocket = [[AsyncSocket alloc] initWithDelegate:self];
    clients =[[NSMutableArray alloc] initWithCapacity:1];
	[self setIsRunning:NO];
    [self setIsHandShaken:NO];
    headerInfo = [[NSMutableDictionary alloc] init];
    notificationCenter = [NSNotificationCenter defaultCenter];
    [listenersocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    return self;
}

+ (WebSocketServer *)startThreaded:(NSNumber *)port{
	WebSocketServer *server = [[WebSocketServer alloc] init];
	[server performSelector:@selector(start:) withObject:port afterDelay:1.0];
	[[NSRunLoop currentRunLoop] run];
	return server;
}

- (void)start:(NSNumber *)nport {
    int port = [nport intValue];
	if (![self isRunning]) {
        if (port < 0 || port > 65535)
			port = 0;
		
        NSError *error = nil;
		if (![listenersocket acceptOnPort:port error:&error]){
			TLog(@"Error listening to %@",error);
			return;
		}
		
        [self setIsRunning:YES];
    } else {
        [listenersocket disconnect];
        [self setIsRunning:false];
    }
}

- (void)stop {
    [listenersocket disconnect];
}

- (void)dealloc {
    [super dealloc];
    [listenersocket disconnect];
    [listenersocket dealloc];
	[headerInfo release];
	[util release];
}

- (NSData *)frameData :(NSData *)payload{
	char initFlag ='\x00';
	char endFlag = '\xff';
	NSData *begin =[NSData dataWithBytes:&initFlag length:1];
	NSData *end = [NSData dataWithBytes:&endFlag length:1];
	NSMutableData *ret = [[NSMutableData alloc] initWithCapacity:2];
	[ret appendData:begin];
	[ret appendData:payload];
	[ret appendData:end];
	return ret;
}

- (void)sendMessage:(NSString *)message toClient:(int)clientId{
    NSData *payload = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *packet = [self frameData:payload];
	TLog(@"sending to websocket %@",packet);
	AsyncSocket *s = [clients objectAtIndex:clientId];
	if (s!=NULL) 
		[s writeData:packet withTimeout:-1 tag:0];	
}

- (void)broadcastMessage:(NSString *)message{
	for (int i=0;i<[clients count]; i++)
			[self sendMessage:message toClient:i];
}
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
	[clients addObject:newSocket];
}

- (void)parseHandshake:(NSString *)message{

	TLog(@"%@",[util stringToHex:message]);
	NSArray *pieces = [message componentsSeparatedByString:@"\r\n"];
	//The first line of the request is always  /GET....
	for(int i =1; i < [pieces count];i++){
		TLog(@"%@",[pieces objectAtIndex:i]);
		NSArray *dictpieces = [[pieces objectAtIndex:i] componentsSeparatedByString:@": "];
		if([dictpieces count] == 2)
			[headerInfo setValue:[dictpieces objectAtIndex:1] forKey:[dictpieces objectAtIndex:0]];
		else 
			if([[pieces objectAtIndex:i] length	] > 2){
				TLog(@"%@",[util stringToHex:[pieces objectAtIndex:i]]);
				assert([[pieces objectAtIndex:i] length	] == 8);
				[headerInfo setValue:[pieces objectAtIndex:i] forKey:@"rand"];
				
			}
	}
	
}
- (BOOL)sendHandshake {
	int sp1,sp2;
	NSMutableString *ourHandshake = [[NSMutableString alloc] initWithCapacity:100];
    [ourHandshake appendString:@"HTTP/1.1 101 Web Socket Protocol Handshake\r\n"];
	[ourHandshake appendString:@"Upgrade: WebSocket\r\n"];
    [ourHandshake appendString:@"Connection: Upgrade\r\n"];
    [ourHandshake appendString:@"Sec-WebSocket-Origin: file://\r\n"];
    [ourHandshake appendString:@"Sec-WebSocket-Location: ws://localhost:50000/websession\r\n"];
    [ourHandshake appendString:@"\r\n"];
	
	
	NSUInteger key1 = [util getKeyValue:[headerInfo objectForKey:@"Sec-WebSocket-Key1"] numberOfSpaces:&sp1];
	NSUInteger key2 = [util getKeyValue:[headerInfo objectForKey:@"Sec-WebSocket-Key2"] numberOfSpaces:&sp2];
	
	assert((key1 % sp1) == 0 && (key2 % sp2) == 0);
	uint32 p1 = key1/sp1;
	uint32 p2 = key2/sp2;
	
	NSData *md5chllg =[util calculateChallenge:p1 number2:p2 rand:[headerInfo objectForKey:@"rand"]];
	
	NSData *response = [ourHandshake dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableData *chg = [[NSMutableData alloc]initWithCapacity:20];
	[chg appendData:response];
	[chg appendData:md5chllg];
#if DEBUG
	NSString *ver = [[NSString alloc]initWithBytes:[chg bytes] length:[chg length] encoding:NSASCIIStringEncoding]; 
	TLog(@"Response printed.\n%@",ver);
	TLog(@"Response in hex\n%@",[util stringToHex:ver]);
#endif

	AsyncSocket *c= [clients objectAtIndex:0];
	[c writeData:chg withTimeout:-1 tag:0];
	
	
/*	[self sendMessage:@"1 10 10" toClient:(int)0];
	[self sendMessage:@"1 10 11" toClient:0];
	[self sendMessage:@"1 10 12" toClient:0];*/
	return NO;	
}

#pragma mark AsyncSocket Delegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"New client connected  %@:%hu", host, port);
	[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *message = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	
    if (message){
        if(!isHandShaken){
            [self parseHandshake:message];
			[self sendHandshake];
			NSNumber *client = [NSNumber numberWithInt:0];
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:kNotificationNewClient object:client];
		
        }else{
            TLog(@"Incoming data from webclient");
        }
    }
    else
        TLog(@"Error converting received data into UTF-8 String");
	
    //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:kNotificationMessage];
    //[notificationCenter postNotificationName:kNotification object:self userInfo:userInfo];
	
	//[sock readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:0];
	[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	TLog(@"%@",@"writting data");
	//[sock readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    TLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
}
- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(CFIndex)partialLength tag:(long)tag{
	TLog(@"socket wrote partial data");
}

@end
