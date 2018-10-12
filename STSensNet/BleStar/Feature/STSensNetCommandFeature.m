/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

#import "STSensNetCommandFeature.h"

#import <BlueSTSDK/BlueSTSDKFeature_pro.h>
#import <BlueSTSDK/BlueSTSDKFeatureField.h>
#import <BlueSTSDK/NSData+NumberConversion.h>

#define FEATURE_NAME @"Command"
#define COMMAND_START_SCANNING 1
#define COMMAND_STOP_SCANNING 2

#define COMMAND_DATA_NAME  @"CommandId"
#define COMMAND_DATA_UNIT nil
#define DATA_MAX @(0xFF)
#define DATA_MIN @(0x00)

#define COMMAND_PAYLOAD_DATA_NAME  @"Command data"
#define COMMAND_PAYLOAD_DATA_UNIT nil

 /**
 * @memberof STSensNetCommandFeature
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@interface STSensNetCommandFeatureListener : NSObject<BlueSTSDKFeatureDelegate>
    -(instancetype)initWithCommandFeature:(STSensNetCommandFeature*)commandFeature;
@end

@implementation STSensNetCommandFeatureListener{
    STSensNetCommandFeature *mCommandFeature;
}

-(instancetype)initWithCommandFeature:(STSensNetCommandFeature*)commandFeature{
    self = [super init];
    mCommandFeature=commandFeature;
    return self;
}

-(void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    uint8_t commandId = [STSensNetCommandFeature getCommandId:sample];
    STSensNetCommandFeature *temp = (STSensNetCommandFeature*)feature;
    if(temp.delegate==nil)
        return;
    //else
    if(commandId == COMMAND_START_SCANNING)
        [temp.delegate onScanIsStarted:temp];
    if(commandId == COMMAND_STOP_SCANNING)
        [temp.delegate onScanIsStopped:temp];
}

@end

@implementation STSensNetCommandFeature{
    id<BlueSTSDKFeatureDelegate> mFeatureListener;
}
    +(void)initialize{
        if(self == [STSensNetCommandFeature class]){
            sFieldDesc = @[[BlueSTSDKFeatureField  createWithName:COMMAND_DATA_NAME
                                                             unit:COMMAND_DATA_UNIT
                                                             type:BlueSTSDKFeatureFieldTypeUInt8
                                                              min:DATA_MIN
                                                              max:DATA_MAX],
                           [BlueSTSDKFeatureField  createWithName:COMMAND_PAYLOAD_DATA_NAME
                                                             unit:COMMAND_PAYLOAD_DATA_UNIT
                                                             type:BlueSTSDKFeatureFieldTypeUInt8Array
                                                              min:DATA_MIN
                                                              max:DATA_MAX]
                           ];
        }//if
    }//initialize

+(uint8_t)getCommandId:(BlueSTSDKFeatureSample*) sample{
    if(sample.data.count>0)
        return [(NSNumber*) sample.data[0] unsignedCharValue];
    return -1;
}

+(NSData*)getCommandData:(BlueSTSDKFeatureSample*) sample{
    NSArray<NSNumber *> *data = sample.data;
    uint8_t temp;
    NSMutableData *outData= [NSMutableData dataWithCapacity:sizeof(temp)*data.count];
    for(NSUInteger i=1;i<data.count;i++){
        temp = [data[i] unsignedCharValue];
        [outData appendBytes:&temp length:sizeof(temp)];
    }
    return  outData;

}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}

-(void)setDelegate:(id<STSensNetCommandFeatureCallback>)delegate{
    _delegate=delegate;
    if(delegate!=nil){
        mFeatureListener = [[STSensNetCommandFeatureListener alloc]initWithCommandFeature:self];
        [self addFeatureDelegate:mFeatureListener];
    }else
        [self removeFeatureDelegate:mFeatureListener];
}

-(BOOL)startScanning{
    return [self sendCommand:COMMAND_START_SCANNING data:nil];
}

-(BOOL)stopScanning{
    return [self sendCommand:COMMAND_STOP_SCANNING data:nil];
}


-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData
                            dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 1){
        @throw [NSException
                exceptionWithName:@"Invalid Command Feature data"
                reason:@"The feature need almost 1 byte for extract the data"
                userInfo:nil];
    }//if
    
    uint8_t commandId= [rawData extractUInt8FromOffset:offset];
    
    NSArray *data = @[@(commandId)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:1];
    
}

@end
