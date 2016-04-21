//
//  ClassificationTestDetail.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 4/20/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ClassificationTestDetail.h"


@implementation ClassificationTestDetail


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.title=@"All Gesture Set";
}

-(IBAction)closeDetailView{
	[self dismissModalViewControllerAnimated:YES];
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
