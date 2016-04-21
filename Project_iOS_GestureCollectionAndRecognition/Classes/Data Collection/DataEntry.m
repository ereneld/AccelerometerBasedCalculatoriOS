//
//  DataEntry.m
//  GestureData
//
//  Created by dogukan erenel on 4/12/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "DataEntry.h"
#import "Person.h"
#import "AgeEntryController.h"
#import "SexEntryController.h"
#import "JobEntryController.h"
#import "EducationEntryController.h"
#import "AbilityEntryController.h"
#import "HandSideController.h"

@implementation DataEntry

@synthesize labelSimple;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	person=[Person getInstance];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		self.title=@"Data Entry";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.title=@"Back";
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.title=@"Geri";
}
*/

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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"table_cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"table_cell"] autorelease];
    }
    if (indexPath.section==0) {
		if (indexPath.row==0) {
			cell.textLabel.text=[NSString stringWithFormat:@"Age: %d" , person.age];
		}
		else if (indexPath.row==1) {
			cell.textLabel.text=[NSString stringWithFormat:@"Sex: %@" , person.sex];
		}
		else if (indexPath.row==2) {
			if ([person disability]) {
				cell.textLabel.text=@"Visually Impaired: YES";
			}
			else {
				cell.textLabel.text=@"Visually Impaired: NO";
			}
			
		}
		else if (indexPath.row==3) {
			cell.textLabel.text=[NSString stringWithFormat:@"Education: %@" , [person educationTypeString]];
		}
		else if (indexPath.row==4) {
			cell.textLabel.text=[NSString stringWithFormat:@"Job: %@" , [person jobTypeString]];
		}
		else if (indexPath.row==5) {
			cell.textLabel.text=[NSString stringWithFormat:@"Hand Usage: %@" , person.hand ];
		}
        else if (indexPath.row==6) {
			cell.textLabel.text=[NSString stringWithFormat:@"Current Hand: %@" , person.handCurrent ];
		}
		
	}
    // Set up the cell...
	cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.row==0) {
		AgeEntryController *ageEntryController = [[AgeEntryController alloc] initWithNibName:@"AgeEntryController" bundle:nil];
        ageEntryController.title=@"Age Entry";
        [[self navigationController] pushViewController:ageEntryController animated:YES];
		[ageEntryController release];
	}
	else if (indexPath.row==1) {
		SexEntryController *sexEntryController = [[SexEntryController alloc] initWithNibName:@"SexEntryController" bundle:nil];
        sexEntryController.title=@"Sex Entry";
        [[self navigationController] pushViewController:sexEntryController animated:YES];
		[sexEntryController release];
	}
	else if (indexPath.row==2) {
		AbilityEntryController *abilityEntryController = [[AbilityEntryController alloc] initWithNibName:@"AbilityEntryController" bundle:nil];
        abilityEntryController.title=@"Disability Status";
		[[self navigationController] pushViewController:abilityEntryController animated:YES];
		[abilityEntryController release];
	}
	else if (indexPath.row==3) {
		EducationEntryController *educationEntryController = [[EducationEntryController alloc] initWithNibName:@"EducationEntryController" bundle:nil];
        educationEntryController.title=@"Education Info";
		[[self navigationController] pushViewController:educationEntryController animated:YES];
		[educationEntryController release];
	}
	else if (indexPath.row==4) {
		JobEntryController *jobEntryController = [[JobEntryController alloc] initWithNibName:@"JobEntryController" bundle:nil];
        jobEntryController.title = @"Job Selection";
		[[self navigationController] pushViewController:jobEntryController animated:YES];
		[jobEntryController release];
	}
	else if (indexPath.row==5) {
		HandSideController *handEntryController = [[HandSideController alloc] initWithNibName:@"HandSideController" bundle:nil];
        handEntryController.title=@"Personal Hand Usage";
        [[self navigationController] pushViewController:handEntryController animated:YES];
		[handEntryController release];
	}
    else if (indexPath.row==6) {
		HandSideController *handEntryController = [[HandSideController alloc] initWithNibName:@"HandSideController" bundle:nil];
        handEntryController.title=@"Current Hand Usage";
        handEntryController.isCurrentHand = YES;
        [[self navigationController] pushViewController:handEntryController animated:YES];
		[handEntryController release];
	}
}


-(IBAction)fillRandomly:(id)sender{
	person.age = 1;
	person.sex = @"?";
	person.disability = NO;
	person.hand = @"?";
    person.handCurrent = @"?";
	[person setJobType:UnknownJob ];
	[person setEducationType:UnknownEducation ];
	[self.tableView reloadData];
}


- (void)dealloc {
    [super dealloc];
}


@end

