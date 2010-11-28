#include <unistd.h>
#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>
#include "Multitouch.h"

/*
Costantino Pistagna <valvoline@gmail.com>

This code will read raw input from all multi-touch devices attached to chain deviceList.
Either if you're dealing with a trackpad or magic mouse, you'll get the raw multi-touch taps.

touchCallback function uses the nFinger parameter to detect a multitouch event. We don't want to
detect the one finger gestures.

If you don't want to handle a gesture, just return null from the callback function.

Compile with:

gcc -o main main.m -F/System/Library/PrivateFrameworks -framework MultitouchSupport -lIOKit \
-framework CoreFoundation -framework ApplicationServices -lobjc

If you make something usefull with this proof of concept, notify me, and i'll wrote some lines
on my page at: http://aladino.dmi.unict.it

*/








//just output debug info. use it to see all the raw infos dumped to screen
void printDebugInfos(int nFingers, Touch *data) {
	int i;
	for (i=0; i<nFingers; i++) {
		Touch *f = &data[i];
		printf("Finger: %d, frame: %d, timestamp: %f, ID: %d, state: %d, PosX: %f, PosY: %f, VelX: %f, VelY: %f, Angle: %f, MajorAxis: %f, MinorAxis: %f\n", i,
			   f->frame,
			   f->timestamp,
			   f->identifier,
			   f->state,
			   f->normalized.position.x,
			   f->normalized.position.y,
			   f->normalized.velocity.x,
			   f->normalized.velocity.y,
			   f->angle,
			   f->majorAxis,
			   f->minorAxis);
	}
}

dataCallback myFunc;
//this's a simple touchCallBack routine. handle your events here
int touchCallback(int device, Touch *data, int nFingers, double timestamp, int frame) {

	myFunc(nFingers,data);
	/*
	 //if we pinch-in (zoom-in)
	 if(distAB > 0.40 && distAB < 0.41) {
	 printf("pinch-in detected\n");
	 
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)55, true); // command (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)69, true); // + (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)69, false); // + (out)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)55, false); // command (out)
	 } else if(distAB < 0.80 && distAB > 0.79) { //if we pinch-out (zoom-out)
	 printf("pinch-out detected\n");
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)55, true); // command (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)78, true); // command (hit)
	 CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)78, false); // command (hit)
	 */
return 0;
}


int startMultitouch(void (*TouchFunc)) {
	int i;
	myFunc = TouchFunc;
	NSMutableArray* deviceList = (NSMutableArray*)MTDeviceCreateList(); //grab our device list
	for(i = 0; i<[deviceList count]; i++) { //iterate available devices
		MTRegisterContactFrameCallback([deviceList objectAtIndex:i], touchCallback); //assign callback for device
		MTDeviceStart([deviceList objectAtIndex:i], 0); //start sending events
	}
	//sleep(-1);
	printf("Ctrl-C to abort\n");
	return 0;
}
