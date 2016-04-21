//
//  DataEntry.h
//  GestureData
//
//  Created by dogukan erenel on 4/12/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;

@interface DataEntry : UITableViewController {
	
	UILabel* labelSimple;
	Person* person;
	
	IBOutlet UIView* ageView;
}

@property (nonatomic, retain) IBOutlet UILabel* labelSimple;

-(IBAction)fillRandomly:(id)sender;

@end
