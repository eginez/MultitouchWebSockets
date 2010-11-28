#import "Utilities.h"
#include <openssl/md5.h>

@implementation WebSocketUtilities


- (NSString *) stringToHex:(NSString *)str{   
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
	
    NSMutableString *hexString = [[NSMutableString alloc] init];
	
    for(int i = 0; i < len; i++ )
		[hexString appendString:[NSString stringWithFormat:@"0x%02x ", chars[i]]];
    
    free(chars);
	
    return [hexString autorelease];
}


- (NSUInteger)getKeyValue:(NSString *)key numberOfSpaces:(int *)spaces{

	(*spaces)=0;
	NSUInteger value=0;
	for (int i=0;i < [key length]; i++){
		char c =[key characterAtIndex:i];
		switch(c){
			case '0'...'9':
				value=value*10 +(int)c - '0';
				break;
			case ' ':
				(*spaces)++;
				break;
			default:
				break;
		}
		
	}

	return value;
}

- (NSData *)calculateChallenge:(uint32 ) num1 number2:(uint32 )num2 rand:(NSString *)rand{
	uint n1 = NSSwapHostIntToBig(num1);
	uint n2 = NSSwapHostIntToBig(num2);
	unsigned char r[8];
	
	NSMutableData *chg = [[NSMutableData alloc]initWithCapacity:16];
	NSData *d1 = [NSData dataWithBytes:&n1 length:4];
	NSData *d2 = [NSData dataWithBytes:&n2 length:4];
	[chg appendData:d1];
	[chg appendData:d2];
	for(int i=0; i<8; i++)
		r[i] = [rand characterAtIndex:i];
	NSData *d3 = [NSData dataWithBytes:r length:8]; 
	[chg appendData:d3];

	NSMutableData *digest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
    MD5([chg bytes],[chg length],[digest mutableBytes]);
	
	TLog(@"num1 is %ld",num1);
	TLog(@"num2 is %ld",num2);
	TLog(@"num1 big endian is %@",[self stringToHex:[[NSString alloc] initWithData:d1 encoding:NSASCIIStringEncoding]]);
	TLog(@"num2 big endian is %@",[self stringToHex:[[NSString alloc] initWithData:d2 encoding:NSASCIIStringEncoding]]);
	TLog(@"random  string is %@", rand);
	TLog(@"random string bytes in hex %@",[self stringToHex:[[NSString alloc] initWithData:d3 encoding:NSASCIIStringEncoding]]);
	TLog(@"challenge  printed\n%@",[[NSString alloc] initWithData:chg encoding:NSUTF8StringEncoding]);
	TLog(@"challenge in hex %@",[self stringToHex:[[NSString alloc] initWithData:chg encoding:NSASCIIStringEncoding]]);
	TLog(@"digest is %@",digest);
	
	return digest;
	
}
@end
