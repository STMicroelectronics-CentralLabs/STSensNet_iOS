/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
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
import Foundation

public class GetNodeSensorResponseParser{
    
    private enum NodeSensorId:UInt8{
        case Temperature=0x10
        case Pressure=0x20
        case Humidity=0x30
        case Acceleration=0x40
        case Gyroscope=0x80
        case Magnetometer=0x90
        //LedDimming=0x70,
        //Distance=0x80,
        //PersonPresence=0x60;
    };
    
    static func parse(data:Data, from node:LPBleNetworkAddress) -> LPBleSensorNode?{
        let nsData = data as NSData
        var offset:Int = 0
        let shortNodeAdr = nsData.extractBeUInt16(fromOffset: UInt(offset))
        if(shortNodeAdr != node.getShortAddres()){
            return nil;
        }
        offset = offset + 2
        
        var temperature:Float = .nan
        var pressure:Float = .nan
        var humidity:Float = .nan
        
        var accX:Int16 = 0
        var accY:Int16 = 0
        var accZ:Int16 = 0
        
        var magX:Int16 = 0
        var magY:Int16 = 0
        var magZ:Int16 = 0
        
        var gyroX:Float = .nan
        var gyroY:Float = .nan
        var gyroZ:Float = .nan
        
        while offset != data.count {
            if let sensorId = NodeSensorId(rawValue: data[offset]){
                offset = offset+1
                switch(sensorId){
                    case .Temperature:
                        temperature  = Float(nsData.extractLeInt16(fromOffset: UInt(offset)))/10.0
                        offset = offset + 2
                        break;
                    case .Pressure:
                        pressure  = Float(nsData.extractLeInt16(fromOffset: UInt(offset)))*16
                        offset = offset + 2
                        break;
                    case .Humidity:
                        humidity = Float(nsData.extractLeInt16(fromOffset: UInt(offset)))
                        offset = offset + 2
                        break;
                    case .Acceleration:
                        accX = nsData.extractLeInt16(fromOffset: UInt(offset))
                        offset = offset + 2
                        accY = nsData.extractLeInt16(fromOffset: UInt(offset))
                        offset = offset + 2
                        accZ = nsData.extractLeInt16(fromOffset: UInt(offset))
                        offset = offset + 2
                        break
                    case .Gyroscope:
                        gyroX = Float(nsData.extractLeInt16(fromOffset: UInt(offset)))/10.0
                        offset = offset + 2
                        gyroY = Float(nsData.extractLeInt16(fromOffset: UInt(offset)))/10.0
                        offset = offset + 2
                        gyroZ = Float(nsData.extractLeInt16(fromOffset: UInt(offset)))/10.0
                        offset = offset + 2
                        break
                    case .Magnetometer:
                        magX = nsData.extractLeInt16(fromOffset: UInt(offset))
                        offset = offset + 2
                        magY = nsData.extractLeInt16(fromOffset: UInt(offset))
                        offset = offset + 2
                        magZ = nsData.extractLeInt16(fromOffset: UInt(offset))
                        offset = offset + 2
                        break
                }
            }else{
                break;
            }
        }
        
        return LPBleSensorNode(address: node, temperature: temperature,
                          pressure: pressure, humidity: humidity, accX: accX,
                          accY: accY, accZ: accZ,
                          magX: magX, magY: magY, magZ: magZ,
                          gyroX: gyroX, gyroY: gyroY, gyroZ: gyroZ);
   }
    
}
