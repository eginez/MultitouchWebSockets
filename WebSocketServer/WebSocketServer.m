
#import "WebSocketServer.h"
#import "AsyncSocket.h"
#import "Utilities.h"


NSString * const kNotification = @"kNotification";
NSString * const kNotificationMessage = @"kNotificationMessage";

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
    //notificationCenter = [NSNotificationCenter defaultCenter];
    [listenersocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	
	
    return self;
}

- (void)start:(NSNumber *)nport {
    int port = [nport intValue];
	if (![self isRunning]) {
        if (port < 0 || port > 65535)
			port = 0;
		
        NSError *error = nil;
		if (![listenersocket acceptOnPort:port error:&error]){
			NSLog(@"Error listening to %@",error);
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
	NSLog(@"%@",packet);
	AsyncSocket *s = [clients objectAtIndex:clientId];
	[s writeData:packet withTimeout:-1 tag:0];	
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
	[clients addObject:newSocket];
}

- (void)parseHandshake:(NSString *)message{

	NSLog(@"%@",[util stringToHex:message]);
	NSArray *pieces = [message componentsSeparatedByString:@"\r\n"];
	//The first line of the request is always  /GET....
	for(int i =1; i < [pieces count];i++){
		NSLog(@"%@",[pieces objectAtIndex:i]);
		NSArray *dictpieces = [[pieces objectAtIndex:i] componentsSeparatedByString:@": "];
		if([dictpieces count] == 2)
			[headerInfo setValue:[dictpieces objectAtIndex:1] forKey:[dictpieces objectAtIndex:0]];
		else 
			if([[pieces objectAtIndex:i] length	] > 2){
				NSLog(@"%@",[util stringToHex:[pieces objectAtIndex:i]]);
				assert([[pieces objectAtIndex:i] length	] == 8);
				[headerInfo setValue:[pieces objectAtIndex:i] forKey:@"rand"];
				
			}
	}
	
	
}
- (BOOL)sendHandshake {
	NSMutableString *ourHandshake = [[NSMutableString alloc] initWithCapacity:100];
    [ourHandshake appendString:@"HTTP/1.1 101 Web Socket Protocol Handshake\r\n"];
	[ourHandshake appendString:@"Upgrade: WebSocket\r\n"];
    [ourHandshake appendString:@"Connection: Upgrade\r\n"];
    [ourHandshake appendString:@"Sec-WebSocket-Origin: file://\r\n"];
    [ourHandshake appendString:@"Sec-WebSocket-Location: ws://localhost:50000/websession\r\n"];
    [ourHandshake appendString:@"\r\n"];
	
	int sp1,sp2;
	NSUInteger key1 = [util getKeyValue:[headerInfo objectForKey:@"Sec-WebSocket-Key1"] numberOfSpaces:&sp1];
	NSUInteger key2 = [util getKeyValue:[headerInfo objectForKey:@"Sec-WebSocket-Key2"] numberOfSpaces:&sp2];
	
	assert((key1 % sp1) == 0 && (key2 % sp2) == 0);
	uint32 p1 = key1/sp1;
	uint32 p2 = key2/sp2;
	
	NSData *md5chllg =[util calculateChallenge:p1 number2:p2 rand:[headerInfo objectForKey:@"rand"]];

	//NSLog(@"we respond is %@",ourHandshake);
	//NSLog(@"we respond is %@",[util stringToHex:ourHandshake]);
	NSData *response = [ourHandshake dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableData *chg = [[NSMutableData alloc]initWithCapacity:20];
	[chg appendData:response];
	[chg appendData:md5chllg];
	
	NSString *ver = [[NSString alloc]initWithBytes:[chg bytes] length:[chg length] encoding:NSASCIIStringEncoding]; 
	NSLog(@"all data in printed\n%@",ver);
	NSLog(@"all data in hex\n%@",[util stringToHex:ver]);

	AsyncSocket *c= [clients objectAtIndex:0];
	[c writeData:chg withTimeout:-1 tag:0];
	[self sendMessage:@"1 10 10" toClient:(int)0];
	[self sendMessage:@"1 10 11" toClient:0];
	[self sendMessage:@"1 10 12" toClient:0];
	return NO;	
}

#pragma mark AsyncSocket Delegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"New client connected  %@:%hu", host, port);
	[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *message = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	//NSString *message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
    if (message){
       // NSLog(@"%@", message);
        if(!isHandShaken){
            [self parseHandshake:message];
			[self sendHandshake];
			//[sock writeData:@"asd" withTimeout:-1 tag:0];
        }else{
            NSLog(@"Incoming data from webclient");
        }
    }
    else
        NSLog(@"Error converting received data into UTF-8 String");
	
    //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:kNotificationMessage];
    //[notificationCenter postNotificationName:kNotification object:self userInfo:userInfo];
	
	//[sock readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:0];
	[sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	NSLog(@"%@",@"writting data");
	//[sock readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]);
}
- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(CFIndex)partialLength tag:(long)tag{
	NSLog(@"socket wrote partial data");
}

@end
