/*
     File: MainViewController.m
 Abstract: Responsible for all UI interactions with the user and the accelerometer
  Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

#import "MainViewController.h"
#import "GraphView.h"
#import "AccelerometerFilter.h"
/*accelerometer simulator*/
//#import "zUIAccelerometer.h"
/*accelerometer simulator*/

#define kUpdateFrequency	60.0
#define kLocalizedPause		NSLocalizedString(@"Pause","pause taking samples")
#define kLocalizedResume	NSLocalizedString(@"Resume","resume taking samples")
#define kFilteringFactor 0.1

#define K_IS_ADAPTIVE_FILTER 0
#define K_IS_FILTER_ON 1
#define K_UPDATE_FREQUENCY 60.0f
#define K_CUTOFF_FREQUENCY 5.0f
#define K_ACCELEROMETER_MIN_STEP		0.02
#define K_ACCELEROMETER_NOISE_ATTENUATION	3.0


@interface MainViewController()

// Sets up a new filter. Since the filter's class matters and not a particular instance
// we just pass in the class and -changeFilter: will setup the proper filter.
-(void)changeFilter:(Class)filterClass;

@end

@implementation MainViewController

@synthesize unfiltered, filtered, buttonPause, filterLabel;
@synthesize labelActualX, labelActualY, labelActualZ;
@synthesize labelFilteredX, labelFilteredY, labelFilteredZ, labelAmplitude, labelFilteredAmplitude;

/*accelerometer simulator*/
//zUIAccelerometer *am;
/*accelerometer simulator*/

// Implement viewDidLoad to do additional setup after loading the view.
-(void)viewDidLoad
{
	[super viewDidLoad];
	
	//buttonPause.possibleTitles = [NSSet setWithObjects:kLocalizedPause, kLocalizedResume, nil];
	isPaused = NO;
	useAdaptive = NO;
	[self changeFilter:[LowpassFilter class]];
	startingTimeInterval = 0.0; 
	accelX = 0.0;
	accelY = 0.0;
	accelZ = 0.0; 
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	
	// Configure and start the accelerometer
	/*accelerometer simulator*/
    //am = [zUIAccelerometer alloc];
    //[am setDelegate:self];
    //[am startFakeAccelerometer];    
    //[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    //[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	/*accelerometer simulator*/
	
	[unfiltered setIsAccessibilityElement:YES];
	[unfiltered setAccessibilityLabel:NSLocalizedString(@"unfilteredGraph", @"")];

	[filtered setIsAccessibilityElement:YES];
	[filtered setAccessibilityLabel:NSLocalizedString(@"filteredGraph", @"")];
}

-(void)viewDidUnload
{
	[super viewDidUnload];
	self.unfiltered = nil;
	self.filtered = nil;
	self.buttonPause = nil;
	self.filterLabel = nil;
}


-(void) viewWillDisappear:(BOOL)animated{
	if (!isPaused) {
		[self pauseOrResume:nil];
	}
	else {
		//do nothing
	}

}

#pragma mark Filtering Code

// UIAccelerometerDelegate method, called when the device accelerates.

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// Update the accelerometer graph view
	if(!isPaused)
	{
		double amplitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2) ) ;
		double amplitudeFilter = sqrt(pow(filter.x, 2) + pow(filter.y, 2) + pow(filter.z, 2) ) ;
		
		[filter addAcceleration:acceleration];
		[unfiltered addX:acceleration.x y:acceleration.y z:acceleration.z t:amplitude];
		[filtered addX:filter.x y:filter.y z:filter.z t:amplitudeFilter];
		
		[labelAmplitude setText:[NSString stringWithFormat:@"%g", amplitude]];
		[labelFilteredAmplitude setText:[NSString stringWithFormat:@"%g", amplitudeFilter]];
		
		[labelActualX setText:[NSString stringWithFormat:@"%g",acceleration.x]];
		[labelActualY setText:[NSString stringWithFormat:@"%g",acceleration.y]];
		[labelActualZ setText:[NSString stringWithFormat:@"%g",acceleration.z]];
 
		[labelFilteredX setText:[NSString stringWithFormat:@"%g",filter.x]];
		[labelFilteredY setText:[NSString stringWithFormat:@"%g",filter.y]];
		[labelFilteredZ setText:[NSString stringWithFormat:@"%g",filter.z]];
 
		if (startingTimeInterval == 0) {
			startingTimeInterval = acceleration.timestamp;
		}
		
		//NSLog(@"Acceleration	t:%f x:%g y:%g z:%g", acceleration.timestamp - startingTimeInterval, acceleration.x, acceleration.y, acceleration.z);
	
		// Subtract the low-pass value from the current value to get a simplified high-pass filter
		accelX = acceleration.x - ( (acceleration.x * kFilteringFactor) + (accelX * (1.0 - kFilteringFactor)) );
		accelY = acceleration.y - ( (acceleration.y * kFilteringFactor) + (accelY * (1.0 - kFilteringFactor)) );
		accelZ = acceleration.z - ( (acceleration.z * kFilteringFactor) + (accelZ * (1.0 - kFilteringFactor)) );
		
		//NSLog(@"Filtered1		t:%f x:%g y:%g z:%g", acceleration.timestamp - startingTimeInterval, accelX, accelY, accelZ);
	
		//NSLog(@"Filtered2		t:%f x:%g y:%g z:%g", acceleration.timestamp - startingTimeInterval, filter.x, filter.y, filter.z);
		
	}
}


// UIAccelerometerDelegate method, called when the device accelerates.
/*accelerometer simulator
//- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
- (void)accelerometer:(zUIAccelerometer *)accelerometer didAccelerate:(zUIAcceleration *)acceleration {
	//accelerometer simulator
	
	if(!isPaused)
	{
		[filter addAcceleration:acceleration];
		[unfiltered addX:acceleration.x y:acceleration.y z:acceleration.z];
		[filtered addX:filter.x y:filter.y z:filter.z];
		
		[labelActualX setText:[NSString stringWithFormat:@"%g",acceleration.x]];
		[labelActualY setText:[NSString stringWithFormat:@"%g",acceleration.y]];
		[labelActualZ setText:[NSString stringWithFormat:@"%g",acceleration.z]];
		
		[labelFilteredX setText:[NSString stringWithFormat:@"%g",filter.x]];
		[labelFilteredY setText:[NSString stringWithFormat:@"%g",filter.y]];
		[labelFilteredZ setText:[NSString stringWithFormat:@"%g",filter.z]];
	}
	
	// Release resources.
}
 */

-(void)changeFilter:(Class)filterClass
{
	// Ensure that the new filter class is different from the current one...
	if(filterClass != [filter class])
	{
		// And if it is, release the old one and create a new one.
		[filter release];
		filter = [[filterClass alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
		// Set the adaptive flag
		filter.adaptive = useAdaptive;
		// And update the filterLabel with the new filter name.
		filterLabel.text = filter.name;
	}
}

-(IBAction)pauseOrResume:(id)sender
{
	startingTimeInterval = 0.0; 
	if(isPaused)
	{
		// If we're paused, then resume and set the title to "Pause"
		isPaused = NO;
		[buttonPause setTitle:kLocalizedPause forState:UIControlStateNormal];
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	}
	else
	{
		// If we are not paused, then pause and set the title to "Resume"
		isPaused = YES;
		[buttonPause setTitle:kLocalizedResume forState:UIControlStateNormal];
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	}
	
	// Inform accessibility clients that the pause/resume button has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

-(IBAction)filterSelect:(id)sender
{
	if([sender selectedSegmentIndex] == 0)
	{
		// Index 0 of the segment selects the lowpass filter
		[self changeFilter:[LowpassFilter class]];
	}
	else
	{
		// Index 1 of the segment selects the highpass filter
		[self changeFilter:[HighpassFilter class]];
	}

	// Inform accessibility clients that the filter has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

-(IBAction)adaptiveSelect:(id)sender
{
	// Index 1 is to use the adaptive filter, so if selected then set useAdaptive appropriately
	useAdaptive = [sender selectedSegmentIndex] == 1;
	// and update our filter and filterLabel
	filter.adaptive = useAdaptive;
	filterLabel.text = filter.name;
	
	// Inform accessibility clients that the adaptive selection has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

-(void)dealloc
{
	// clean up everything.
	[unfiltered release];
	[filtered release];
	[filterLabel release];
	[buttonPause release];
	[super dealloc];
}

@end
