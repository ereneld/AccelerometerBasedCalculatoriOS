//
//  HandSideController.m
//  GestureData
//
//  Created by dogukan erenel on 5/13/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "HandSideController.h"
#import "Person.h"

@implementation HandSideController

@synthesize isCurrentHand;
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
    NSString* selectedHand = @"";
    if (isCurrentHand) {
       selectedHand =  [Person getInstance].handCurrent;
    }
    else{
        selectedHand =  [Person getInstance].hand;
    }
   
    if ([selectedHand isEqualToString:@"L"]) {
        [handSelection setSelectedSegmentIndex:0];
    }
    else if([selectedHand isEqualToString:@"L"]) {
         [handSelection setSelectedSegmentIndex:1];
    }
    else{
        [handSelection setSelectedSegmentIndex:2];
    }
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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


-(void)viewDidDisappear:(BOOL)animated{
	NSString* selectedHand;
	if (handSelection.selectedSegmentIndex==0) {
		selectedHand=@"L";
	}
	else if (handSelection.selectedSegmentIndex==1) {
		selectedHand=@"R";
	}
	else {
		selectedHand=@"?";
	}
	
     if (isCurrentHand) {
         [[Person getInstance] setHandCurrent:selectedHand] ;
     }
     else{
         [[Person getInstance] setHand:selectedHand] ;
     }
	
}

- (void)dealloc {
    [super dealloc];
}


@end
