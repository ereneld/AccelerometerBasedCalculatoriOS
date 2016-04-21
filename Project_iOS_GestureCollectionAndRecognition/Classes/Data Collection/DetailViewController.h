//
//  DetailViewController.h
//  GestureData
//
//  Created by dogukan erenel on 4/14/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mach/mach_time.h>

@class Person;
@class GestureData;

@interface DetailViewController : UIViewController <UIAccelerometerDelegate> {

	UIImageView* gestureImageView;
	UILabel* gestureText;
	
	NSInteger gestureIndex;
	BOOL isStopped;
	
	Person* person;
	GestureData* currentGestureData;
	NSTimeInterval startingTimeInterval;
	
	/* Get the timebase info */
	mach_timebase_info_data_t info;
	uint64_t startedTime ;
	
}

@property (nonatomic, retain) IBOutlet UIImageView* gestureImageView;
@property (nonatomic, retain) IBOutlet UILabel* gestureText;
@property (nonatomic, assign) NSInteger gestureIndex;

-(IBAction) startRecordGestureData:(id)sender;
-(IBAction) stopRecordGestureData:(id)sender;

-(void)setGestureDetail;
- (NSString *)getDocumentsDirectory;

@end
