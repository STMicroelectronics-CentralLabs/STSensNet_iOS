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

#import <BlueSTSDK/BlueSTSDK.h>


/**
 *Feature used for send system commands to the BlueStar Fw
 */
@protocol STSensNetCommandFeatureCallback;

/**
 * Feature for send system command to the board
 */
@interface STSensNetCommandFeature : BlueSTSDKFeature


/**
 * Object where notify the command results
 */
@property (nonatomic,retain) id<STSensNetCommandFeatureCallback> delegate;


/**
 * Send a command for start the scanning of new nodes
 * @return true if the command is correctly send
 */
-(BOOL)startScanning;


/**
 * Send a command for stop the scanning of new nodes
 *
 * @return
 */
-(BOOL)stopScanning;

/**
 * extract the command id form a response message

 @param sample feature data
 @return command id
 */
+(uint8_t)getCommandId:(BlueSTSDKFeatureSample*) sample;

/**
 * extract the command data from a response message

 @param sample feature data
 @return command payload, can have lenght 0 if no data are present
 */
+(NSData*)getCommandData:(BlueSTSDKFeatureSample*) sample;

@end

@protocol STSensNetCommandFeatureCallback <NSObject>

/**
 * function called when the node notify that the scan for new nodes is started
 *
 * @param commandFeature object where the command is sent
 */
-(void)onScanIsStarted:(STSensNetCommandFeature*)commandFeature;

/**
 * function called when the node notify that the scan for new node is stopped

 @param commandFeature object where the command is sent
 */
-(void)onScanIsStopped:(STSensNetCommandFeature*)commandFeature;

@end
