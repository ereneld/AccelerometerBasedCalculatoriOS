//
//  ClassificationString.h
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 5/1/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClassificationString : NSObject {
    
}

+(NSString*)getClassifiedClassString:(int)classIndex;
+(NSString*)getClassMovementString:(int)classIndex;
+(NSString*)getClassMeaningString:(int)classIndex;
+(NSString*)getCalculatorStringForSpeaking:(NSString*)calculatorString;


@end
