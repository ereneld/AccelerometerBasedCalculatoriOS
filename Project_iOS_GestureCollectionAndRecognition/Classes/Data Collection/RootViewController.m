//
//  RootViewController.m
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright Bogazici University 2010. All rights reserved.
//

#import "RootViewController.h"
#import "Person.h"
#import "DetailViewController.h"
#import "DataEntry.h"
#import "GestureDataAppDelegate.h"

@implementation RootViewController

@synthesize person;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	isAllDataOk=NO;
	isPersonalDataOk=NO;
	
	person=[Person getInstance];

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	 self.title=@"Hand Gesture Data Entry";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	 [tableView reloadData];
	
	isAllDataOk=YES;
	for (int i=0; i<[person.allGestureData count]; i++) {
		if (! [(GestureData*)[person.allGestureData objectAtIndex:i] isGestureFilled]) {
			isAllDataOk=NO;
		}
	}
	if (isAllDataOk) {
		NSLog(@"All Gesture Data Saved - Thanks");
		viewThankYou.hidden = NO;
	}
	else {
		viewThankYou.hidden = YES;
	}

}

-(IBAction)restartDataCollection{
	[Person resetWithSamePersonalInformation];
	viewThankYou.hidden = YES;
	[tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.title=@"Back";
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger returnValue= 0;
	if (section==0) {
		returnValue=1;
	}
	else if(section==1){
		returnValue=[person.allGestureData count];
	}
	else {
		returnValue=0;
	}

    return returnValue;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	//NSLog(@" Index path section: %d, row : %d", indexPath.section,  indexPath.row);
	
	if (indexPath.section==0 && indexPath.row==0) {
		if (person !=nil && person.age>0 && person.sex!=nil && ![[person sex] isEqualToString:@""]) {
			NSString* yesNoForDisability= person.disability == YES ? @"E" : @"H";
			cell.textLabel.text= [NSString stringWithFormat:@"Age: %d, Sex: %@, Disability: %@", person.age, person.sex, yesNoForDisability];
			cell.backgroundColor=[UIColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1.0];
			isPersonalDataOk=YES;
		}
		else {
			cell.textLabel.text= @" Personal Information ";
			cell.backgroundColor=[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
			isPersonalDataOk=NO;
		}
		cell.imageView.image=nil;
	}
	else {
		//NSInteger gestureType = indexPath.row/8 + 1;
		//NSInteger gestureMovementType = (indexPath.row % 8) + 1;
		//[(GestureData*)[person.allGestureData objectAtIndex:indexPath.row] gestureTitle ]
		//cell.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%d%d.png",gestureType,gestureMovementType]];
		cell.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [(GestureData*)[person.allGestureData objectAtIndex:indexPath.row] gestureTitle ]]];
		
		
		if ([ (GestureData *)[person.allGestureData objectAtIndex:indexPath.row] isGestureFilled]) {
			cell.textLabel.text= [NSString stringWithFormat:@"Gesture Saved"];
			cell.backgroundColor=[UIColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1.0];
		}
		else {
			cell.textLabel.text= [NSString stringWithFormat:@"Waiting Gesture"];
			cell.backgroundColor=[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
		}

		
	}

	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    //cell.textLabel.text= [NSString stringWithFormat:@" Hucre at : %d", indexPath.row];
	// Configure the cell.

    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* returnValue= @"";
	if (section == 0) {
		returnValue=@"Personal Information";
	}
	else if (section == 1) {
		int totalGestureGathered=0;
		for (int i=0; i<[person.allGestureData count]; i++) {
			if ([(GestureData*)[person.allGestureData objectAtIndex:i] isGestureFilled ]) {
				totalGestureGathered += 1;
			}
		}
		returnValue=[NSString stringWithFormat:@"Hand Gesture (%d / %d)",totalGestureGathered, [person.allGestureData count]];
	}
	else {
		returnValue=@"? ? ?";
	}
	
	return returnValue;
}

/*
-(UITableViewCellAccessoryType) tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator; 
}
*/

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section==0) {
		DataEntry *anotherViewController = [[DataEntry alloc] initWithNibName:@"DataEntry" bundle:nil];
		[self.navigationController pushViewController:anotherViewController animated:YES];
		[anotherViewController release];
	}
	if (indexPath.section==1) {
		if (isPersonalDataOk) {
			DetailViewController *anotherViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
			
			//NSInteger gestureType = indexPath.row/8 + 1;
			//NSInteger gestureMovementType = (indexPath.row % 8) + 1;
			
			[self.navigationController pushViewController:anotherViewController animated:YES];
			//anotherViewController.gestureImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%x%x.png",gestureType,gestureMovementType]];
			anotherViewController.gestureImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [(GestureData*)[person.allGestureData objectAtIndex:indexPath.row] gestureTitle ]]];
			
			//anotherViewController.gestureText.text=[NSString stringWithFormat:[NSString stringWithFormat:@"%x%x",gestureType,gestureMovementType]];
			anotherViewController.gestureText.text=[(GestureData*)[person.allGestureData objectAtIndex:indexPath.row] gestureTitle ];
			
			anotherViewController.gestureIndex=indexPath.row;
			[anotherViewController setGestureDetail];
			
			[anotherViewController release];
		}
		else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}

		
		/*
		
		 */
	}
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





- (void)dealloc {
    [super dealloc];
}


@end

