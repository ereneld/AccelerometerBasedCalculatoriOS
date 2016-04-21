//
//  HandSideController.h
//  GestureData
//
//  Created by dogukan erenel on 5/13/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HandSideController : UIViewController {
	IBOutlet UISegmentedControl* handSelection;
    
    BOOL isCurrentHand;
    
}
@property(nonatomic, assign) BOOL isCurrentHand;

@end
