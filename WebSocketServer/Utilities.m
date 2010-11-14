#import "Utilities.h"
#include <openssl/md5.h>

@implementation WebSocketUtilities


- (NSString *) stringToHex:(NSString *)str{   
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
	
    NSMutableString *hexString = [[NSMutableString alloc] init];
	
    for(NSUInteger i = 0; i < len; i++ )
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
	NSMutableData *chg = [[NSMutableData alloc]initWithCapacity:16];
	NSData *d1 = [NSData dataWithBytes:&n1 length:4];
	NSData *d2 = [NSData dataWithBytes:&n2 length:4];
	int size;
	[chg appendData:d1];
	size = [chg length];
	[chg appendData:d2];
	size = [chg length];
	
	int s2= [rand length];
	unsigned char r[8];
	for(int i=0; i<8; i++)
		r[i] = [rand characterAtIndex:i];
	char * utfs = [rand UTF8String];
	
	//NSData *d3 = [rand dataUsingEncoding:NSASCIIStringEncoding];
	//NSData *d3 = [NSData dataWithBytes:utfs length:8];
	NSData *d3 = [NSData dataWithBytes:r length:8]; 
		
	[chg appendData:d3];
	 size = [chg length];
	char *t="a";

	NSData *ddg = [rand dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *digest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
    MD5([chg bytes],[chg length],[digest mutableBytes]);
    size = strlen(digest);
    //	fprintf(stderr,"digest is %s",digest);
    fprintf(stderr,"size of digest is %d\n",size);
	
	NSLog(@"num1 ois %ld",num1);
	NSLog(@"num1 is %ld",num2);
	NSLog(@"n1 is %@",[self stringToHex:[[NSString alloc] initWithData:d1 encoding:NSASCIIStringEncoding]]);
	NSLog(@"n2 is %@",[self stringToHex:[[NSString alloc] initWithData:d2 encoding:NSASCIIStringEncoding]]);
	NSLog(@"n3 string is %@", rand);
	NSLog(@"n3 is %@",[self stringToHex:[[NSString alloc] initWithData:d3 encoding:NSASCIIStringEncoding]]);
	NSLog(@"all in printed\n%@",[[NSString alloc] initWithData:chg encoding:NSUTF8StringEncoding]);
	NSLog(@"all is %@",[self stringToHex:[[NSString alloc] initWithData:chg encoding:NSASCIIStringEncoding]]);
	//NSLog(@"md5 is %@",[NSString stringWithUTF8String:digest]);
	NSLog(@"digest is %@",digest);
	
	
	
		  
	
	//return [NSString stringWithCString:(char *)digest];
	return digest;
	
}
@end
