//
//  CellViewData.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 4/12/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "CellViewData.h"


@implementation CellViewData

@synthesize labelTime, labelX, labelY, labelZ, labelCluster;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)showGestureData:(GestureData*)gestureData andRow:(int)rowIndex{
    
    double time = [[[gestureData.gestureData objectAtIndex:0]objectAtIndex:rowIndex] doubleValue];
    double xValue = [[[gestureData.gestureData objectAtIndex:1]objectAtIndex:rowIndex] doubleValue];
    double yValue = [[[gestureData.gestureData objectAtIndex:2]objectAtIndex:rowIndex] doubleValue];
    double zValue = [[[gestureData.gestureData objectAtIndex:3]objectAtIndex:rowIndex] doubleValue];
    double cValue = [[[gestureData.gestureData objectAtIndex:4]objectAtIndex:rowIndex] doubleValue];
    
    labelTime.text = [NSString stringWithFormat:@"%g", time];
    labelX.text = [NSString stringWithFormat:@"%g", xValue];
    labelY.text = [NSString stringWithFormat:@"%g", yValue];
    labelZ.text = [NSString stringWithFormat:@"%g", zValue];
    labelCluster.text = [NSString stringWithFormat:@"%g", cValue];
     
}


- (void)dealloc
{
    [super dealloc];
}

@end
