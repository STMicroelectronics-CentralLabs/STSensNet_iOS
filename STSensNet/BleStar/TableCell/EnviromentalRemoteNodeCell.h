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

#import <UIKit/UIKit.h>
#import "EnviromentalRemoteNodeData.h"

/**
 *  protocol where the cell will notify a change in the led switch
 */
@protocol EnviromentalRemoteNodeCellChanges <NSObject>

/**
 *  method called when the use change the led switch status
 *
 *  @param nodeId remote node that contains the led to change
 *  @param state  new led state
 */
-(void)ledStatusDidChangeForNodeId:(uint16_t)nodeId newState:(bool)state;

@end

/**
 *  content of a table cell, this will show the temperature, pressure, humidity 
 * and led status of a remote node. The user can change the led status. This change
 * will notify using the EnviromentalRemoteNodeCellChanges delegate.
 */
@interface EnviromentalRemoteNodeCell : UITableViewCell

/**
 *  Delegate used for notify the led status change
 */
@property id<EnviromentalRemoteNodeCellChanges> envDelegate;

/**
 * id of the node used for filled this table cell
 */
@property uint16_t nodeId;


/**
 *  set the unit to use when display a pressure data
 *
 *  @param unit unit to use for the pressure data
 */
+(void)setPressureUnit:(NSString*)unit;

/**
 *  set the unit to use when display a temperature data
 *
 *  @param unit unit to use for the temperature data
 */
+(void)setTemperatureUnit:(NSString*)unit;

/**
 *  set the unit to use when display a humidity data
 *
 *  @param unit unit to use for the humidity data
 */
+(void)setHumidityUnit:(NSString*)unit;

/**
 * set the unit to use when display a luminosity data
 * @param unit unit to use for the luminosity data
 */
+(void)setLuminosityUnit:(NSString*)unit;

/**
 *  sync the displed data with the one inside the EnviromentalRemoteNodeData object
 *
 *  @param data data to display in this cell
 */
-(BOOL)updateContent:(EnviromentalRemoteNodeData*)data;

@end
