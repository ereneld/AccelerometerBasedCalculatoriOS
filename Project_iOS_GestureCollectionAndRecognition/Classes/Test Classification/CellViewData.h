//
//  CellViewData.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 4/12/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureData.h"

@interface CellViewData : UITableViewCell {
    
    UILabel* labelTime;
    UILabel* labelX;
    UILabel* labelY;
    UILabel* labelZ;
    UILabel* labelCluster;
    
}

@property(nonatomic, retain)IBOutlet UILabel* labelTime;
@property(nonatomic, retain)IBOutlet UILabel* labelX;
@property(nonatomic, retain)IBOutlet UILabel* labelY;
@property(nonatomic, retain)IBOutlet UILabel* labelZ;
@property(nonatomic, retain)IBOutlet UILabel* labelCluster;

-(void)showGestureData:(GestureData*)gestureData andRow:(int)rowIndex;

@end
