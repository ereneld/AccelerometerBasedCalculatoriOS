//
//  EducationEntryController.m
//  GestureData
//
//  Created by dogukan erenel on 4/15/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "EducationEntryController.h"
#import "Person.h"

@implementation EducationEntryController

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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

/*
-(UITableViewCellAccessoryType) tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==[[Person getInstance] educationType]) {
		return UITableViewCellAccessoryCheckmark; 
	}
	else {
		return UITableViewCellAccessoryNone; 
	}

	
}
*/
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Education"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell_Education"] autorelease];
    }
    if (indexPath.section==0) {
		cell.textLabel.text = [[Person getInstance]educationTypeString:indexPath.row];
		/*if (indexPath.row==0) {
			cell.textLabel.text=@"No Education";
		}
		else if (indexPath.row==1) {
			cell.textLabel.text=@"Unknown Education";
		}
		else if (indexPath.row==2) {
			cell.textLabel.text=@"Read Write";
		}
		else if (indexPath.row==3) {
			cell.textLabel.text=@"Elementery School";
		}
		else if (indexPath.row==4) {
			cell.textLabel.text=@"High-School";
		}
		else if (indexPath.row==5) {
			cell.textLabel.text=@"UnderGraduate";
		}
		else if (indexPath.row==6) {
			cell.textLabel.text=@"Master Degree";
		}
		else if (indexPath.row==7) {
			cell.textLabel.text=@"Phd Degree";
		}
		else if (indexPath.row==8) {
			cell.textLabel.text=@"Professor";
		}
		*/
		
	}
    // Set up the cell...
	
	if (indexPath.row==[[Person getInstance] educationType]) {
		cell.accessoryType=UITableViewCellAccessoryCheckmark; 
	}
	else {
		cell.accessoryType=UITableViewCellAccessoryNone; 
	}
	
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	if (indexPath.row==0) {
		[[Person getInstance] setEducationType:NoEducation ];
	}
	else if (indexPath.row==1) {
		[[Person getInstance] setEducationType:UnknownEducation ];
	}
	else if (indexPath.row==2) {
		[[Person getInstance] setEducationType:ReadWrite ];	
	}
	else if (indexPath.row==3) {
		[[Person getInstance] setEducationType:ElementerySchool ];
	}
	else if (indexPath.row==4) {
		[[Person getInstance] setEducationType:HighSchool ];
	}
	else if (indexPath.row==5) {
		[[Person getInstance] setEducationType:UnderGraduate ];
	}
	else if (indexPath.row==6) {
		[[Person getInstance] setEducationType:MasterDegree ];
	}
	else if (indexPath.row==7) {
		[[Person getInstance] setEducationType:PhdDegree ];
	}
	else if (indexPath.row==8) {
		[[Person getInstance] setEducationType:Professor ];
	}
	[tableView reloadData];
}

- (void)dealloc {
    [super dealloc];
}


@end
