//
//  RootViewController.h
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright Bogazici University 2010. All rights reserved.
//

@class Person;

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	Person *person;
	
	IBOutlet UITableView* tableView;
	IBOutlet UIView* viewThankYou;
	bool isAllDataOk;
	bool isPersonalDataOk;
}

@property(nonatomic,retain) Person* person;

-(IBAction)restartDataCollection;


@end
