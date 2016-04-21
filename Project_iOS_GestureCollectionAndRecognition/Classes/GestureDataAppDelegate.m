//
//  GestureDataAppDelegate.m
//  GestureData
//
//  Created by dogukan erenel on 4/11/10.
//  Copyright Bogazici University 2010. All rights reserved.
//

#import "GestureDataAppDelegate.h"
#import "RootViewController.h"

#import "ConfigurationManager.h"

#import "Calculator.h"
#import "TTS.h"

@implementation GestureDataAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
 
    
    //ISpeechSDK* testSpeech = [ISpeechSDK ISpeech:@"" provider:@"" application:@""];
    //[testSpeech ISpeechSpeak:@"I am making test to speech..."];
    [TTS startSpeakText:@"Welcome to Gesture Recognition Program"];
    // Override point for customization after app launch    
    [ConfigurationManager initializeParameters];
    [ConfigurationManager loadConfigurationList]; //We should put the configuration PLIST into document folder!!!
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


/*Calculator* testCalculator = [[Calculator alloc]init];
 [testCalculator addItem:@"D"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"*"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"1"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"="];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"1"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"1"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"-"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"0"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"2"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"*"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"2"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"0"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"="];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"D"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"D"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"D"];
 NSLog(@"%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"D"];
 NSLog(@"Log :%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"D"];
 NSLog(@"Log :%@", [testCalculator getCalculatorString]);
 [testCalculator addItem:@"D"];
 NSLog(@"Log :%@", [testCalculator getCalculatorString]);
 */

@end

