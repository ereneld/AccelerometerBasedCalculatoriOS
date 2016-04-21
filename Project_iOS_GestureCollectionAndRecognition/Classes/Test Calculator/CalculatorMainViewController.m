//
//  CalculatorMainViewController.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 3/17/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "CalculatorMainViewController.h"

#import "CalculatorDetailViewController.h"
#import "Constants.h"

#import "Filter.h"
#import "DimensionalReductor.h"
#import "Cluster.h"
#import "Sampler.h"
#import "Preprocessor.h"
#import "NoiseEliminator.h"
#import "CrossValidator.h"
#import "Classifier.h"
#import "TTS.h"
#import "ClassificationString.h"

@implementation CalculatorMainViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [TTS startSpeakText:@"To use calculator, make your movement while iPhone face to you and pressing the screen."];
    
    calculator = [[Calculator alloc]init];
    
    labelCalculator.text = @"0";
    labelLastGesture.text = @"?";
    labelLastRealGestureNo.text = @"";
    
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.title=@"Gesture Calculator";
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
    int predictedClassId = [ConfigurationManager getClassificationResult:currentGestureData];
    if (predictedClassId>=19) {
        predictedClassId += 2;
    }
    else if (predictedClassId>=9) {
        predictedClassId += 1;
    }
    else{
        //do nothing
    }
    
    [self addCalculatorString:predictedClassId];
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


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)addCalculatorString:(int)classifiedClass{
    
   NSString* classifiedString = [ClassificationString getClassifiedClassString:classifiedClass];
   NSString* calculatorString =@"" ;
    
    if (classifiedClass>0) {
        
        if (classifiedString && ![classifiedString isEqualToString:@""]) {
            if (![classifiedString isEqualToString:@"="]) {
                [TTS startSpeakText:[ClassificationString getClassMeaningString:classifiedClass]];
            }
            
            [calculator addItem:classifiedString];
            calculatorString = [calculator getCalculatorMeaningString];
            labelLastGesture.text = classifiedString;
        }
        else{
            calculatorString = [calculator getCalculatorMeaningString];
            [TTS startSpeakText:calculatorString];
        }
        
        imageRealGesture.hidden = NO;
        NSString* imageOfPredictionClass = [NSString stringWithFormat:@"%d.png",classifiedClass];
        if (classifiedClass<10) {
            imageOfPredictionClass = [NSString stringWithFormat:@"0%d.png",classifiedClass];
        }
        imageRealGesture.image=[UIImage imageNamed:imageOfPredictionClass];
    }
    else{
        imageRealGesture.hidden = YES;
         labelLastGesture.text = @"?";
    }
    
    labelLastRealGestureNo.text = [NSString stringWithFormat:@"%d", classifiedClass];
    
    [self updateCalculatorText];
    
    if ([classifiedString isEqualToString:@"="]) {
        NSString* resultString = [NSString stringWithFormat:@"Result is, %@ ", [ClassificationString getCalculatorStringForSpeaking:calculatorString]];
        [TTS startSpeakText:resultString];
    }
}

-(void)updateCalculatorText{
    NSString* calculatorString = [calculator getCalculatorString];
    if (calculatorString && [calculatorString length]>0) {
         labelCalculator.text = calculatorString;
    }
    else{
         labelCalculator.text = @"0";
    }
   
}


-(IBAction)showDetail{
	if (!detailViewController) {
		detailViewController=[[CalculatorDetailViewController alloc]initWithNibName:@"CalculatorDetailViewController" bundle:nil];
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
