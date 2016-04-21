//
//  DetailViewController.m
//  GestureData
//
//  Created by dogukan erenel on 4/14/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "DetailViewController.h"
#import "Person.h"
#import "GestureData.h"
#import "Constants.h"


@implementation DetailViewController

@synthesize gestureImageView, gestureText, gestureIndex;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {
    [super viewDidLoad];
	
	isStopped=YES;
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / K_UPDATE_FREQUENCY];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];

}

- (NSString *)getDocumentsDirectory {  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    return [paths objectAtIndex:0];  
}  

-(void) viewWillDisappear:(BOOL)animated{
	isStopped=YES;
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
	if ([currentGestureData isGestureFilled]) {
		
		NSDate *date = [NSDate date];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"D-H-m-ss"];
		
		//NSInteger gestureType = gestureIndex/8 + 1;
		//NSInteger gestureMovementType = (gestureIndex % 8) + 1;
		//NSString* gestureDataName=[NSString stringWithFormat:@"/%d%d", gestureType, gestureMovementType];
		NSString* gestureDataName=[NSString stringWithFormat:@"/%@",[(GestureData*)[person.allGestureData objectAtIndex:gestureIndex] gestureTitle ]];
		gestureDataName=[gestureDataName stringByAppendingString:[NSString stringWithFormat:@"_%@_%@.plist",[person personDescription], [formatter stringFromDate:date]]] ;
		//NSLog(gestureDataName);
		[formatter release];
		
		NSString *pathForFile =[[self getDocumentsDirectory] stringByAppendingString:gestureDataName] ;
		//[currentGestureData.gestureData writeToFile:pathForFile atomically:YES];
		
		NSMutableDictionary* dictionaryForPlistToSave = [[NSMutableDictionary alloc]init];
		[dictionaryForPlistToSave setValue:[(GestureData*)[person.allGestureData objectAtIndex:gestureIndex] gestureTitle] forKey:@"GESTUREDATA_TITLE"];
		[dictionaryForPlistToSave setValue:[(GestureData*)[person.allGestureData objectAtIndex:gestureIndex] gestureTitle] forKey:@"GESTUREDATA_IMAGENUMBER"];
		[dictionaryForPlistToSave setValue:[NSNumber numberWithInt:person.age] forKey:@"GESTUREDATA_AGE"];
		[dictionaryForPlistToSave setValue:person.sex forKey:@"GESTUREDATA_SEX"];
		[dictionaryForPlistToSave setValue:person.hand forKey:@"GESTUREDATA_HAND"];
        [dictionaryForPlistToSave setValue:person.handCurrent forKey:@"GESTUREDATA_CURRENT_HAND"];
		[dictionaryForPlistToSave setValue:[NSNumber numberWithBool:person.disability] forKey:@"GESTUREDATA_DISABILITY"];
		[dictionaryForPlistToSave setValue:[NSNumber numberWithInt:[person jobType]] forKey:@"GESTUREDATA_JOBTYPE"];
		[dictionaryForPlistToSave setValue:[NSNumber numberWithInt:[person educationType]] forKey:@"GESTUREDATA_EDUCATIONTYPE"];
		[dictionaryForPlistToSave setValue:date forKey:@"GESTUREDATA_DATE"];
		[dictionaryForPlistToSave setValue:currentGestureData.gestureData forKey:@"GESTUREDATA_DATA"];
		
		[dictionaryForPlistToSave writeToFile:pathForFile atomically:YES];
		
		NSLog(@"Saved gesture data: %@", gestureDataName);
	}
	
}

-(void)setGestureDetail{
	person=[Person getInstance];
	currentGestureData=[person.allGestureData objectAtIndex:gestureIndex];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction) startRecordGestureData:(id)sender{
	startingTimeInterval = 0.0;
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:0] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:1] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:2] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:3] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:4] removeAllObjects];
	
	isStopped=NO;
	/* Get the timebase info
	mach_timebase_info(&info);
	startedTime = mach_absolute_time();
	 */
	
}

-(IBAction) stopRecordGestureData:(id)sender{
	isStopped=YES;
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	// Update the accelerometer graph view
	if(!isStopped)
	{
		/*uint64_t duration = mach_absolute_time() - startedTime;
		// Convert to nanoseconds
		duration *= info.numer;
		duration /= info.denom;
		double amplitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2) ) ;
		 */
		 
		 //[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:0] addObject: [NSNumber numberWithUnsignedLongLong:duration]];
		if (startingTimeInterval == 0) {
			startingTimeInterval = acceleration.timestamp;
		}
		
		 [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:0] addObject: [NSNumber numberWithDouble:(acceleration.timestamp - startingTimeInterval)]];
		 [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:1] addObject: [NSNumber numberWithDouble:acceleration.x]];
		 [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:2] addObject: [NSNumber numberWithDouble:acceleration.y]];
		 [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:3] addObject: [NSNumber numberWithDouble:acceleration.z]];
		 [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:4] addObject: [NSNumber numberWithInt:0]];
		 //[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:4] addObject: [NSNumber numberWithDouble:amplitude]];
	}
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
