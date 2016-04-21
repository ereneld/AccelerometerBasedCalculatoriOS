//
//  ConfusionMatrix.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/5/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
							Predicted
							p			n
						Positive	Negative
Actual			p'		a				b
				n'		c				d
 
 
 Example confusion matrix
				Predicted
				Cat	Dog	Rabbit
 Actual	Cat		5	3	0
		Dog		2	3	1
		Rabbit	0	2	11
 
*/

@interface ConfusionMatrix : NSObject {

	int numberOfClass;
	int numberOfClassified;
    int numberOfNonClassified;
    
	int** confusionMatrix;
}

-(id)initWithNumberOfClass:(int)numberOfClassValue;
-(void)addValue:(int)actualClassIndex andPredictedClassIndes:(int)predictedClassIndex;
-(double)getRecallOfAll;
-(NSString*)toString;
	
@end
