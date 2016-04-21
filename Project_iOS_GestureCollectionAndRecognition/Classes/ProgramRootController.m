//
//  ProgramRootController.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 3/16/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ProgramRootController.h"


@implementation ProgramRootController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.title=@"Boun MS Thesis";
	isDetailOpening = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (isDetailOpening) {
		self.title=@"Boun MS Thesis";
	}
	else {
		self.title=@"Back";
	}

	
}

-(IBAction)openAccelerometerUnderstand{
	if (!partAccelerometer) {
		partAccelerometer = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
	}
	[self.navigationController pushViewController:partAccelerometer animated:YES];
}

-(IBAction)openDataCollection{
	if (!partDataCollection) {
		partDataCollection = [[RootViewController alloc]initWithNibName:@"RootViewController" bundle:nil];
	}
	[self.navigationController pushViewController:partDataCollection animated:YES];
}

-(IBAction)openGestureTraining{
	/*if (!partTraining) {
		partTraining = [[GestureTrainingViewController alloc]initWithNibName:@"GestureTrainingViewController" bundle:nil];
	}
	[self.navigationController pushViewController:partTraining animated:YES];
*/
    NSString* messageTitle= @"Coming Soon";
	NSString* messageString= @"Training part should be done in your mac with given framework. \nThen you should put your configuration file under document folder of this application.";
	
	UIAlertView *alertLoginResult = [[UIAlertView alloc] initWithTitle: messageTitle message:messageString delegate:self cancelButtonTitle: @"Okay" otherButtonTitles: nil];
	[alertLoginResult show];
	[alertLoginResult release]; 
}
-(IBAction)openTestClassification{
	if (!partTestClassification) {
		partTestClassification = [[ClassificationTestViewController alloc]initWithNibName:@"ClassificationTestViewController" bundle:nil];
	}
	[self.navigationController pushViewController:partTestClassification animated:YES];
}

-(IBAction)openTestCalculator{
	if (!partCalculator) {
		partCalculator = [[CalculatorMainViewController alloc]initWithNibName:@"CalculatorMainViewController" bundle:nil];
	}
	[self.navigationController pushViewController:partCalculator animated:YES];
}

-(IBAction)openProgramDetail{
	if (!partDetail) {
		partDetail = [[ProgramDetailViewController alloc]initWithNibName:@"ProgramDetailViewController" bundle:nil];
	}
	isDetailOpening = YES;
	[self presentModalViewController:partDetail animated:YES];
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
