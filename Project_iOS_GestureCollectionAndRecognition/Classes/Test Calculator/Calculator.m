//
//  Calculator.m
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 4/20/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "Calculator.h"
#import "ClassificationString.h"

@implementation Term

-(id)initWithTerm:(NSString*)termValueString{
    self = [super init];
    if (self) {
        termString = [[NSString alloc]initWithString:termValueString];
    }
    return self;
}

-(id)initWithTermValue:(double)termValue{
    self = [super init];
    if (self) {
        termString = [[NSString alloc]initWithFormat:@"%g", termValue];
    }
    return self;
}

-(NSString*)toString{
    NSString* returnObject = @"";
    if ([self toValue]>=0) {
         returnObject = termString;
    }
    else{
        returnObject = [NSString stringWithFormat:@"(%@)",termString];
    }
    return returnObject;
}
-(double)toValue{
    /*double returnValue = 0.0;
    if (termString && [termString length]>0) {
        returnValue = [termString doubleValue];
    }
    else{
        returnValue = 0.0;
    }
    return returnValue;
     */
    return [termString doubleValue];
}

-(BOOL)deleteLastDigit{
    BOOL returnValue = NO;
    if ([termString length]>0) {
        if ([self toValue]<0 && [termString length]==2) {
            termString = [[NSString alloc]initWithString:@""]; // @"-1" , delete should give @"" not @"-"
        }
        else{
             termString = [[NSString alloc]initWithString:[termString substringToIndex:[termString length]-1]];
        }
        
        returnValue = YES;
    }
    else{
        returnValue = NO;
    }
    return returnValue;
}
-(BOOL)addLastDigit:(NSString*)termValue{
    BOOL returnValue = NO;
    if ([Term isTerm:termValue]) {
        termString = [[NSString alloc]initWithString:[termString stringByAppendingString:termValue]];
        returnValue = YES;
    }
    else{
        returnValue = NO;
    }
    return returnValue;
    
}

+(BOOL)isTerm:(NSString*)termValue{
    BOOL returnValue = NO;
    if (termValue && [termValue length]==1) {
        if ([termValue intValue] >0 ||[termValue isEqualToString:@"0"] ) {
            returnValue = YES;
        }
    }
    else{
        returnValue = NO;
        //do nothing -> string is nil or greater than 1 decimal
    }
    
    return returnValue;
}
@end

@implementation Operator 
@synthesize  operationType;

-(id)initWithValue:(OperationType)operationTypeValue{
    self = [super init];
    if(self){
        operationType = operationTypeValue;
    }
    return self;
}
-(NSString*)toString{
    NSString* returnObject = @"";
    if (operationType==OperationTypeAddition) {
        returnObject = @"+";
    }
    else if (operationType==OperationTypeSubtraction) {
        returnObject = @"-";
    }
    else if (operationType==OperationTypeMultiplication) {
        returnObject = @"*";
    }
    else if (operationType==OperationTypeDivision) {
        returnObject = @"/";
    }
    return returnObject;
}
@end

@implementation Calculator

-(id)init{
    self = [super init];
    if (self) {
        arrayCalculatorItems = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)addItem:(NSString*)stringItem{
    NSLog(@"Before item :%@ and number of item in calculator %d", stringItem, [arrayCalculatorItems count]);
    NSLog(@"Before item: %@ - calculator: %@",stringItem, [self getCalculatorString]);
    
    NSObject* itemObject = nil;
    
    if ([Term isTerm:stringItem]) {
        NSLog(@"item :%@ is a TERM", stringItem);
        NSObject* lastObject = [arrayCalculatorItems lastObject];
        if ([lastObject isKindOfClass:[Term class]]) {
            [lastObject retain];
            [arrayCalculatorItems removeLastObject];
        }
        itemObject = [self getTerm:stringItem andLastTerm:lastObject];
        [lastObject release];
    }
    else if([self isOperator:stringItem]){
        NSLog(@"item :%@ is a OPERATOR", stringItem);
         itemObject = [self getOperator:stringItem andLastTerm:[arrayCalculatorItems lastObject]];
    }
    else if([self isProcess:stringItem]){
        NSLog(@"item :%@ is a PROCESS", stringItem);
        BOOL isEvaluated = [self evaluateProcess:stringItem];
        if (isEvaluated) {
            NSLog(@"Evaluation is done");
        }
        else{
            NSLog(@"Error - Not evaluated");
        }
        stringItem = nil;  //we process it and no need to add to array!
    }
    else{
        itemObject = nil;
    }
    
    if (itemObject) {
         [arrayCalculatorItems addObject:itemObject];
    }
    
    NSLog(@"After item: %@ - calculator: %@",stringItem, [self getCalculatorString]);
    NSLog(@"After item :%@ and number of item in calculator %d", stringItem, [arrayCalculatorItems count]);
}

-(BOOL)evaluateProcess:(NSString*)processValue{
    BOOL returnValue = YES;
    ProcessType processType = [self getProcessType:processValue];
    if (processType==ProcessTypeDelete) {
        if ([arrayCalculatorItems count]>0) {
            NSObject* lastObject = [arrayCalculatorItems lastObject];
            if ([lastObject isKindOfClass:[Term class]]) {
                if ([[(Term*)lastObject toString] length]>1) {
                    [(Term*)lastObject deleteLastDigit];
                }
                else{
                    [arrayCalculatorItems removeLastObject];
                }
                
            }
            else if([lastObject isKindOfClass:[Operator class]]) {
                [arrayCalculatorItems removeLastObject];
            }
            else{
                // do nothing 
                NSLog(@"ERROR - evaluateProcess");
                returnValue = NO; 
            }
        }
        else{
            returnValue = NO; 
        }
       
    }
    else if(processType==ProcessTypeGiveOutput) {
        if ([arrayCalculatorItems count]>=3) { //the min requirement for an operation
            Term* firstTerm = nil;
            Term* secondTerm = nil;
            Operator* operator = nil;
            double operationResult = 0.0;
            //Search for multiplication
            for (int i=0; i<[arrayCalculatorItems count]; i++) {
                if ([[arrayCalculatorItems objectAtIndex:i]isKindOfClass:[Operator class]]) {
                    operator = [arrayCalculatorItems objectAtIndex:i];
                    if ([self getOperatorType:[operator toString]]==OperationTypeMultiplication ) {
                        if (i>0 && i<[arrayCalculatorItems count]-1 && [[arrayCalculatorItems objectAtIndex:i-1]isKindOfClass:[Term class]] && [[arrayCalculatorItems objectAtIndex:i+1]isKindOfClass:[Term class]]) {
                            firstTerm = [arrayCalculatorItems objectAtIndex:i-1];
                            secondTerm = [arrayCalculatorItems objectAtIndex:i+1];
                            operationResult = [firstTerm toValue] * [secondTerm toValue];
                            [arrayCalculatorItems removeObjectAtIndex:i+1];
                            [arrayCalculatorItems replaceObjectAtIndex:i withObject:[[Term alloc]initWithTermValue:operationResult]];
                            [arrayCalculatorItems removeObjectAtIndex:i-1];
                             i=0;
                        }
                        else{
                            [arrayCalculatorItems removeAllObjects];
                        }
                    }
                }
            }
            //Search for division
            for (int i=0; i<[arrayCalculatorItems count]; i++) {
                if ([[arrayCalculatorItems objectAtIndex:i]isKindOfClass:[Operator class]]) {
                    operator = [arrayCalculatorItems objectAtIndex:i];
                    if ([self getOperatorType:[operator toString]]==OperationTypeDivision ) {
                        if (i>0 && i<[arrayCalculatorItems count]-1 && [[arrayCalculatorItems objectAtIndex:i-1]isKindOfClass:[Term class]] && [[arrayCalculatorItems objectAtIndex:i+1]isKindOfClass:[Term class]]) {
                            firstTerm = [arrayCalculatorItems objectAtIndex:i-1];
                            secondTerm = [arrayCalculatorItems objectAtIndex:i+1];
                            if ([secondTerm toValue]!=0.0) {
                                operationResult = [firstTerm toValue] / [secondTerm toValue];
                                [arrayCalculatorItems removeObjectAtIndex:i+1];
                                [arrayCalculatorItems replaceObjectAtIndex:i withObject:[[Term alloc]initWithTermValue:operationResult]];
                                [arrayCalculatorItems removeObjectAtIndex:i-1];
                                i=0;
                            }
                            else{
                                [arrayCalculatorItems removeAllObjects];
                            }
                           
                        }
                        else{
                            [arrayCalculatorItems removeAllObjects];
                        }
                    }
                }
            }
            //Search for addition
            for (int i=0; i<[arrayCalculatorItems count]; i++) {
                if ([[arrayCalculatorItems objectAtIndex:i]isKindOfClass:[Operator class]]) {
                    operator = [arrayCalculatorItems objectAtIndex:i];
                    if ([self getOperatorType:[operator toString]]==OperationTypeAddition ) {
                        if (i>0 && i<[arrayCalculatorItems count]-1 && [[arrayCalculatorItems objectAtIndex:i-1]isKindOfClass:[Term class]] && [[arrayCalculatorItems objectAtIndex:i+1]isKindOfClass:[Term class]]) {
                            firstTerm = [arrayCalculatorItems objectAtIndex:i-1];
                            secondTerm = [arrayCalculatorItems objectAtIndex:i+1];
                            operationResult = [firstTerm toValue] + [secondTerm toValue];
                            [arrayCalculatorItems removeObjectAtIndex:i+1];
                            [arrayCalculatorItems replaceObjectAtIndex:i withObject:[[Term alloc]initWithTermValue:operationResult]];
                            [arrayCalculatorItems removeObjectAtIndex:i-1];
                             i=0;
                        }
                        else{
                            [arrayCalculatorItems removeAllObjects];
                        }
                    }
                }
            }
            //Search for subtraction
            for (int i=0; i<[arrayCalculatorItems count]; i++) {
                if ([[arrayCalculatorItems objectAtIndex:i]isKindOfClass:[Operator class]]) {
                    operator = [arrayCalculatorItems objectAtIndex:i];
                    if ([self getOperatorType:[operator toString]]==OperationTypeSubtraction ) {
                        if (i>0 && i<[arrayCalculatorItems count]-1 && [[arrayCalculatorItems objectAtIndex:i-1]isKindOfClass:[Term class]] && [[arrayCalculatorItems objectAtIndex:i+1]isKindOfClass:[Term class]]) {
                            firstTerm = [arrayCalculatorItems objectAtIndex:i-1];
                            secondTerm = [arrayCalculatorItems objectAtIndex:i+1];
                            operationResult = [firstTerm toValue] - [secondTerm toValue];
                            [arrayCalculatorItems removeObjectAtIndex:i+1];
                            [arrayCalculatorItems replaceObjectAtIndex:i withObject:[[Term alloc]initWithTermValue:operationResult]];
                            [arrayCalculatorItems removeObjectAtIndex:i-1];
                             i=0;
                        }
                        else{
                            [arrayCalculatorItems removeAllObjects];
                        }
                    }
                }
            }
            
        }
        else{
            [arrayCalculatorItems removeAllObjects];
        }
    }
    else{
        //do nothing
        returnValue = NO;
    }
    
    return returnValue;
}


-(BOOL)isOperator:(NSString*)operatorValue{
    BOOL returnValue = NO;
    if (operatorValue) {
        OperationType operationType = [self getOperatorType:operatorValue];
        if (operationType!=OperationTypeNONE) {
            returnValue = YES;
        }
        else{
            returnValue = NO;
        }
    }
    else{
        //do nothing -> string is nil or greater than 1 decimal
    }
    
    return returnValue;
}

-(OperationType)getOperatorType:(NSString*)operatorValue{
    OperationType returnValue = OperationTypeNONE;
    if (operatorValue) {
        if ([operatorValue isEqualToString:@"+"]) {
            returnValue = OperationTypeAddition;
        }
        else if([operatorValue isEqualToString:@"-"]) {
            returnValue = OperationTypeSubtraction;
        }
        else if([operatorValue isEqualToString:@"*"]) {
            returnValue = OperationTypeMultiplication;
        }
        else if([operatorValue isEqualToString:@"/"]) {
            returnValue = OperationTypeDivision;
        }
        else{
            returnValue = OperationTypeNONE;
        }
    }
    else{
        //do nothing -> string is nil or greater than 1 decimal
    }
    
    return returnValue;
}

-(BOOL)isProcess:(NSString*)processValue{
    BOOL returnValue = NO;
    if (processValue && [processValue length]==1) {
        ProcessType processType = [self getProcessType:processValue];
        if (processType!=ProcessTypeNONE) {
            returnValue = YES;
        }
        else{
            returnValue = NO;
        }
    }
    else{
        //do nothing -> string is nil or greater than 1 decimal
    }
    
    return returnValue;
}

-(ProcessType)getProcessType:(NSString*)processValue{
    ProcessType returnValue = ProcessTypeNONE;
    if (processValue) {
        if ([processValue isEqualToString:@"D"]) {
            returnValue = ProcessTypeDelete;
        }
        else if([processValue isEqualToString:@"="]) {
            returnValue = ProcessTypeGiveOutput;
        }        
        else{
            returnValue = ProcessTypeNONE;
        }
    }
    else{
        //do nothing -> string is nil or greater than 1 decimal
    }
    
    return returnValue;
}

-(Term*)getTerm:(NSString*)termValue andLastTerm:(NSObject*)lastItem{
    Term* returnObject = nil;
    if ([lastItem isKindOfClass:[Term class]]) {
        [(Term*)lastItem addLastDigit:termValue];
        returnObject = [[Term alloc]initWithTermValue:[(Term*)lastItem toValue]];
    }
    else{
        returnObject = [[Term alloc]initWithTerm:termValue];
    }
    return returnObject;
}

-(Operator*)getOperator:(NSString*)operatorValue andLastTerm:(NSObject*)lastItem{
    return [[Operator alloc] initWithValue:[self getOperatorType:operatorValue]];  
}

-(NSString*)getCalculatorString{
    NSString* calculatorString = @"";
    for (NSObject* calculatorItem in arrayCalculatorItems) {
        calculatorString = [calculatorString stringByAppendingString:[calculatorItem toString]];
    }
    
    return calculatorString;
}

-(NSString*)getCalculatorMeaningString{
    NSString* calculatorMeaningString = @"";
    for (NSObject* calculatorItem in arrayCalculatorItems) {
        if ([calculatorItem isKindOfClass:[Term class]]) {
            calculatorMeaningString = [calculatorMeaningString stringByAppendingString:[calculatorItem toString]];
        }
        else if([calculatorItem isKindOfClass:[Operator class]]){
             calculatorMeaningString = [calculatorMeaningString stringByAppendingString:[ClassificationString getCalculatorStringForSpeaking:[calculatorItem toString]]];
        }
        else{
            //do nothing
        }
        
        calculatorMeaningString = [calculatorMeaningString stringByAppendingString:@" "];
    }
    
    return calculatorMeaningString;
}

-(void)dealloc{
    [arrayCalculatorItems release];
    [super dealloc];
}
@end
