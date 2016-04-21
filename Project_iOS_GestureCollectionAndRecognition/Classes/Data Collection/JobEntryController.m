//
//  JobEntryController.m
//  GestureData
//
//  Created by dogukan erenel on 4/15/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "JobEntryController.h"
#import "Person.h"

@implementation JobEntryController

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
    return 10;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Job"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell_Job"] autorelease];
    }
    if (indexPath.section==0) {
		cell.textLabel.text = [[Person getInstance]jobTypeString:indexPath.row];
		/*if (indexPath.row==0) {
			cell.textLabel.text=@"No Job";
		}
		else if (indexPath.row==1) {
			cell.textLabel.text=@"Unknown Job";
		}
		else if (indexPath.row==2) {
			cell.textLabel.text=@"Student";
		}
		else if (indexPath.row==3) {
			cell.textLabel.text=@"Teacher";
		}
		else if (indexPath.row==4) {
			cell.textLabel.text=@"Worker";
		}
		else if (indexPath.row==5) {
			cell.textLabel.text=@"Doctor";
		}
		else if (indexPath.row==6) {
			cell.textLabel.text=@"Engineer";
		}
		else if (indexPath.row==7) {
			cell.textLabel.text=@"Sport Profession";
		}
		else if (indexPath.row==8) {
			cell.textLabel.text=@"Art Profession";
		}
		else if (indexPath.row==9) {
			cell.textLabel.text=@"Other";
		}
		 */
		
	}
    // Set up the cell...
	
	if (indexPath.row==[[Person getInstance] jobType]) {
		cell.accessoryType= UITableViewCellAccessoryCheckmark; 
	}
	else {
		cell.accessoryType= UITableViewCellAccessoryNone; 
	}
	
    return cell;
}

/*
-(UITableViewCellAccessoryType) tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==[[Person getInstance] jobType]) {
		return UITableViewCellAccessoryCheckmark; 
	}
	else {
		return UITableViewCellAccessoryNone; 
	}
	
	
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.row==0) {
		[[Person getInstance] setJobType:NoJob ];
	}
	else if (indexPath.row==1) {
		[[Person getInstance] setJobType:UnknownJob ];
	}
	else if (indexPath.row==2) {
		[[Person getInstance] setJobType:Student ];	
	}
	else if (indexPath.row==3) {
		[[Person getInstance] setJobType:Teacher ];
	}
	else if (indexPath.row==4) {
		[[Person getInstance] setJobType:Worker ];
	}
	else if (indexPath.row==5) {
		[[Person getInstance] setJobType:Doctor ];
	}
	else if (indexPath.row==6) {
		[[Person getInstance] setJobType:Engineer ];
	}
	else if (indexPath.row==7) {
		[[Person getInstance] setJobType:SportProfession ];
	}
	else if (indexPath.row==8) {
		[[Person getInstance] setJobType:ArtProfession ];
	}
	else if (indexPath.row==9) {
		[[Person getInstance] setJobType:Other ];
	}
	[tableView reloadData];
}



- (void)dealloc {
    [super dealloc];
}


@end
