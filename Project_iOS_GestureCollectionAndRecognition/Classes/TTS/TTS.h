//
//  TTS.h
//  GestureDataWithRecognition
//
//  Created by dogukan ibrahimoglu on 5/1/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FliteTTS.h"

@interface TTS : NSObject {
    
}

+(FliteTTS*) getTTS;
+(void)startSpeakText:(NSString *)textToSpeak;
+(void)stopSpeaking;


@end
