//
//  GestureData.m
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright 2010 Bogazici University. All rights reserved.
//

#import "GestureData.h"
#import "Constants.h"

@implementation GestureData

@synthesize gestureData, gestureTitle, gestureFullPath,gestureNumber, gestureNumber_PREDICTED, gestureMainType, gestureMovementType, zKeyValue, isForTraining;

-(BOOL) isGestureFilled{
	return ([(NSMutableArray*)[gestureData objectAtIndex:0] count]!=0);
}


-(NSString*)getDataStringForMatlab{
	NSString* returnValue=@"";
	double currentT = 0.0, currentX = 0.0, currentY=0.0, currentZ=0.0;
	int clusterNumber=0;
	if (gestureData!= nil &&  [gestureData count]>0 && [(NSMutableArray*)[gestureData objectAtIndex:0] count]>0) {
		for(int j=0; j< [(NSMutableArray*)[gestureData objectAtIndex:0] count] ; j++){
			currentT = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:0] objectAtIndex:j] doubleValue];
			currentX = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:1] objectAtIndex:j] doubleValue];
			currentY = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:2] objectAtIndex:j] doubleValue];
			currentZ = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:3] objectAtIndex:j] doubleValue];
			clusterNumber = [(NSNumber*)[(NSMutableArray*)[gestureData objectAtIndex:4] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%g,%g,%g,%g,%d\n" , currentT, currentX, currentY, currentZ, clusterNumber]];
		}
	}
	return returnValue;
}

-(NSString*)getClusterSquenceStringForMatlab{
	NSString* returnValue=@"";
	int clusterNumber=0;
	if (gestureData!= nil &&  [gestureData count]>0 ) {
		int squenceLength = [(NSMutableArray*)[gestureData objectAtIndex:0] count];
		for(float i=0; i< squenceLength; i = i + 1){
			clusterNumber = [[(NSMutableArray*)[gestureData objectAtIndex:4] objectAtIndex:i]intValue];
			if (i==0) {
				returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d" , clusterNumber]];
			}
			else {
				returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@",%d" , clusterNumber]];
			}
		}
	}
	return returnValue;
}
/*
-(NSString*)getStatementIntString{
	NSString* returnValue=@"";
	int currentStateX = 0, currentStateY=0, currentStateZ=0;
	NSMutableArray* tempStateIntArray = gestureStateData_int;
	if (tempStateIntArray!= nil &&  [tempStateIntArray count]>0 && [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count]>0) {
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count] ; j++){
			currentStateX = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:0] objectAtIndex:j] intValue];
			currentStateY = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:1] objectAtIndex:j] intValue];
			currentStateZ = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:2] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d,%d,%d,%d\n",j , currentStateX, currentStateY, currentStateZ]];
		}
	}
	return returnValue;
}
*/
/*

-(NSString*)getStatementIntString{
	NSString* returnValue=@"";
	int currentStateX = 0, currentStateY=0, currentStateZ=0;
	NSMutableArray* tempStateIntArray = gestureStateData_int;
	if (tempStateIntArray!= nil &&  [tempStateIntArray count]>0 && [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count]>0) {
		returnValue = [returnValue stringByAppendingString:@"X: "];
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:0] count] ; j++){
			currentStateX = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:0] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d, \t" , currentStateX]];
		}
		returnValue = [returnValue stringByAppendingString:@" \n"];
		
		returnValue = [returnValue stringByAppendingString:@"Y: "];
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:1] count] ; j++){
			currentStateY = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:1] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d, \t" , currentStateY]];
		}
		returnValue = [returnValue stringByAppendingString:@" \n"];
		
		returnValue = [returnValue stringByAppendingString:@"Z: "];
		for(int j=0; j< [(NSMutableArray*)[tempStateIntArray objectAtIndex:2] count] ; j++){
			currentStateZ = [(NSNumber*)[(NSMutableArray*)[tempStateIntArray objectAtIndex:2] objectAtIndex:j] intValue];
			returnValue = [returnValue stringByAppendingString:[NSString stringWithFormat:@"%d, \t" , currentStateZ]];
		}
		returnValue = [returnValue stringByAppendingString:@" \n"];
		
	}
	return returnValue;
}
*/

@end
