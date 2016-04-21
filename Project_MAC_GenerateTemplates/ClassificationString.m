//
//  ClassificationString.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 5/1/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "ClassificationString.h"


@implementation ClassificationString

+(NSString*)getClassifiedClassString:(int)classIndex{
    NSString* returnValue = @"";
    
    switch (classIndex) {
            //Numbers 0 - 9
        case 9:
            returnValue = @"0";
            break;
        case 10:
            returnValue = @"0";
            break;
        case 1:
            returnValue = @"1";
            break;
        case 4:
            returnValue = @"1";
            break;
        case 13:
            returnValue = @"2";
            break;
        case 14:
            returnValue = @"3";
            break;
        case 5:
            returnValue = @"4";
            break;
        case 15:
            returnValue = @"5";
            break;
        case 16:
            returnValue = @"6";
            break;
        case 6:
            returnValue = @"7";
            break;
        case 17:
            returnValue = @"8";
            break;
        case 18:
            returnValue = @"9";
            break;
            
            //Operaitions + , - , * , /
        case 11:
            returnValue = @"+";
            break;
        case 2:
            returnValue = @"-";
            break;
        case 8:
            returnValue = @"*";
            break;
        case 7:
            returnValue = @"/";
            break;
            //Process  delete, output
        case 3:
            returnValue = @"D";
            break; 
        case 12:
            returnValue = @"=";
            break; 
        default:
            returnValue = @"";
            break;
    }
    
    return returnValue;
}

+(NSString*)getClassMovementString:(int)classIndex{
    NSString* returnValue = @"";
    
    switch (classIndex) {
            //Numbers 0 - 9
        case 9:
            returnValue = @"Left Circle";
            break;
        case 10:
            returnValue = @"Right Circle";
            break;
        case 1:
            returnValue = @"Down arrow";
            break;
        case 4:
            returnValue = @"Up Arrow";
            break;
        case 13:
            returnValue = @"Number 2";
            break;
        case 14:
            returnValue = @"Number 3";
            break;
        case 5:
            returnValue = @"Right Half Square";
            break;
        case 15:
            returnValue = @"Number 5";
            break;
        case 16:
            returnValue = @"Number 6";
            break;
        case 6:
            returnValue = @"Down Half Square";
            break;
        case 17:
            returnValue = @"Number 8";
            break;
        case 18:
            returnValue = @"Number 9";
            break;
            
            //Operaitions + , - , * , /
        case 11:
            returnValue = @"Left Square";
            break;
        case 2:
            returnValue = @"Right Arrow";
            break;
        case 8:
            returnValue = @"Cross";
            break;
        case 7:
            returnValue = @"Triangle";
            break;
            //Process  delete, output
        case 3:
            returnValue = @"Left Arrow";
            break; 
        case 12:
            returnValue = @"Down Square";
            break; 
            // Others
        case 19:
            returnValue = @"Left Circle in Z";
            break;
        case 20:
            returnValue = @"Right Circle in Z";
            break;
        case 21:
            returnValue = @"Left Square in Z";
            break;
        case 22:
            returnValue = @"Down Square in Z";
            break;
        default:
            returnValue = @"none";
            break;
    }

    return returnValue;

}

+(NSString*)getClassMeaningString:(int)classIndex{
    NSString* returnValue = @"";
    
    switch (classIndex) {
            //Numbers 0 - 9
        case 9:
            returnValue = @"0 ";
            break;
        case 10:
            returnValue = @"0 ";
            break;
        case 1:
            returnValue = @"1 ";
            break;
        case 4:
            returnValue = @"1 ";
            break;
        case 13:
            returnValue = @"2 ";
            break;
        case 14:
            returnValue = @"3 ";
            break;
        case 5:
            returnValue = @"4 ";
            break;
        case 15:
            returnValue = @"5 ";
            break;
        case 16:
            returnValue = @"6 ";
            break;
        case 6:
            returnValue = @"7 ";
            break;
        case 17:
            returnValue = @"8 ";
            break;
        case 18:
            returnValue = @"9 ";
            break;
            
            //Operaitions + , - , * , /
        case 11:
            returnValue = @"addition";
            break;
        case 2:
            returnValue = @"subtraction";
            break;
        case 8:
            returnValue = @"multiplication";
            break;
        case 7:
            returnValue = @"division";
            break;
            //Process  delete, output
        case 3:
            returnValue = @"delete";
            break; 
        case 12:
            returnValue = @"result";
            break; 
        default:
            returnValue = @"none";
            break;
    }
    return returnValue;
}

+(NSString*)getCalculatorStringForSpeaking:(NSString*)calculatorString{
    NSString* returnValue = @"";
    
    if ([calculatorString isEqualToString:@"+"]) {
        returnValue = @"addition";
    }
    else if ([calculatorString isEqualToString:@"-"]) {
        returnValue = @"subtraction";
    }
    else if ([calculatorString isEqualToString:@"*"]) {
        returnValue = @"multiplication";
    }
    else if ([calculatorString isEqualToString:@"/"]) {
         returnValue = @"division";
    }
    else{
        returnValue = calculatorString;
    }
    return returnValue;
    
}


@end
