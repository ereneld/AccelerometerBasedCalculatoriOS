//
//  CellViewProbability.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 4/12/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "CellViewProbability.h"
#import "Classifier.h"

@implementation CellViewProbability


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

-(void)showGestureData:(GestureData*)gestureData andClass:(int)classIndex{
    if (gestureData && gestureData.gestureData) {
        double modelProbability = [Classifier getModelProbability:classIndex];
        double sequenceProbability = [Classifier getSequenceProbability:gestureData andModelIndex:classIndex];
        double resultProbability = modelProbability * sequenceProbability;
        
        labelClass.text = [NSString stringWithFormat:@"%d", classIndex];
        labelModelProbability.text = [NSString stringWithFormat:@"%g", modelProbability];
        labelSequenceProbability.text = [NSString stringWithFormat:@"%g", sequenceProbability];
        labelResultProbability.text = [NSString stringWithFormat:@"%g", resultProbability];
    }
    
}

- (void)dealloc
{
    [super dealloc];
}


@end
