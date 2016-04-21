//
//  ClassificationTestViewController.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 3/17/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ClassificationTestViewController.h"
#import "ClassificationDataViewController.h"
#import "ClassificationProbabilitiesViewController.h"
#import "ClassificationTestDetail.h"
#import "Constants.h"

#import "Filter.h"
#import "DimensionalReductor.h"
#import "Cluster.h"
#import "Sampler.h"
#import "Preprocessor.h"
#import "NoiseEliminator.h"
#import "CrossValidator.h"
#import "Classifier.h"

#import "ClassificationString.h"
#import "TTS.h"

@implementation ClassificationTestViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [TTS startSpeakText:@"To test classifier, make your movement while iPhone face to you and pressing the screen."];
    
    isStopped=YES;
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / K_UPDATE_FREQUENCY];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    currentGestureData=[[GestureData alloc]init];
    
    NSMutableArray *arrayForTime = [[NSMutableArray alloc] init];
    NSMutableArray *arrayForX = [[NSMutableArray alloc] init];
    NSMutableArray *arrayForY = [[NSMutableArray alloc] init];
    NSMutableArray *arrayForZ = [[NSMutableArray alloc] init];
    NSMutableArray *arrayForCluster = [[NSMutableArray alloc] init];
    
    currentGestureData.gestureData=[[NSArray alloc] initWithObjects:arrayForTime,arrayForX,arrayForY,arrayForZ, arrayForCluster,nil];

    imageClassificationResult.hidden = YES;
}

-(void) viewWillDisappear:(BOOL)animated{
    isStopped=YES;
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

-(IBAction) startRecordGestureData:(id)sender{
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
	startingTimeInterval = 0.0;
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:0] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:1] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:2] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:3] removeAllObjects];
	[(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:4] removeAllObjects];
	isStopped=NO;
	
}

-(IBAction) stopRecordGestureData:(id)sender{
	isStopped=YES;
    [self showClassificationResult];
    
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	if(!isStopped)
	{
		if (startingTimeInterval == 0) {
			startingTimeInterval = acceleration.timestamp;
		}
		
        [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:0] addObject: [NSNumber numberWithDouble:(acceleration.timestamp - startingTimeInterval)]];
        [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:1] addObject: [NSNumber numberWithDouble:acceleration.x]];
        [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:2] addObject: [NSNumber numberWithDouble:acceleration.y]];
        [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:3] addObject: [NSNumber numberWithDouble:acceleration.z]];
        [(NSMutableArray*)[currentGestureData.gestureData objectAtIndex:4] addObject: [NSNumber numberWithInt:0]];
        
	}
}

-(void)showClassificationResult{
    
    int predictedClassId = [ConfigurationManager getClassificationResult:currentGestureData];
    if (predictedClassId>0) {
        if (predictedClassId>=19) {
            predictedClassId += 2;
        }
        else if (predictedClassId>=9) {
            predictedClassId += 1;
        }
        else{
            //do nothing
        }
        
        [TTS startSpeakText:[ClassificationString getClassMovementString:predictedClassId]];
        
        NSString* imageOfPredictionClass = [NSString stringWithFormat:@"%d.png",predictedClassId];
        if (predictedClassId<10) {
            imageOfPredictionClass = [NSString stringWithFormat:@"0%d.png",predictedClassId];
        }
        imageClassificationResult.image=[UIImage imageNamed:imageOfPredictionClass];
        imageClassificationResult.hidden = NO;
        labelQuestionMark.hidden = YES;
    }
    else{
        imageClassificationResult.hidden = YES;
        labelQuestionMark.hidden = NO;
    }
    
    if (currentGestureData && currentGestureData.gestureData && [currentGestureData isGestureFilled] && predictedClassId>0)
    {
        buttonShowData.enabled = YES;
        buttonShowProbability.enabled = YES;
    }
    else{
        buttonShowData.enabled = NO;
        buttonShowProbability.enabled = NO;
    }
    
}

-(IBAction)showDataView{
    if (currentGestureData && currentGestureData.gestureData && [currentGestureData isGestureFilled]) {
        ClassificationDataViewController *anotherViewController = [[ClassificationDataViewController alloc] initWithNibName:@"ClassificationDataViewController" bundle:nil andGestureData:currentGestureData];
        [self.navigationController pushViewController:anotherViewController animated:YES];
        [anotherViewController release];
    }
      
}

-(IBAction)showProbabityView{
     if (currentGestureData && currentGestureData.gestureData && [currentGestureData isGestureFilled]) {
         ClassificationProbabilitiesViewController *anotherViewController = [[ClassificationProbabilitiesViewController alloc] initWithNibName:@"ClassificationProbabilitiesViewController" bundle:nil andGestureData:currentGestureData];
         [self.navigationController pushViewController:anotherViewController animated:YES];
         [anotherViewController release]; 
     }
}

-(IBAction)showDetail{
	if (!detailViewController) {
		detailViewController=[[ClassificationTestDetail alloc]initWithNibName:@"ClassificationTestDetail" bundle:nil];
	}
	[self presentModalViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
