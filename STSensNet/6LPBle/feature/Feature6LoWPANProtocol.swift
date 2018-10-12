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
import BlueSTSDK

public class Feature6LoWPANProtocol : BlueSTSDKFeature{
    private static let FEATURE_NAME = "6LoWPAN Network Bridge";
    private static let COMMAND_TIMEOUT:DispatchTimeInterval = .seconds(2)
    
    private enum CommandId:UInt16{
        case getNodeList = 0x0030
        case getNodeSensorValue = 0x0032
        case getNetworkTopology = 0x0070
        case changeActuatorState = 0x0051
    }
    
    private let mTimeoutQueue = DispatchQueue(label: "com.st.Feature6LoWPANProtocol")
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [];
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: Feature6LoWPANProtocol.FEATURE_NAME)
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return Feature6LoWPANProtocol.FIELDS;
    }
    
    private var _timestamp = UInt16(0);
    private var timestamp:UInt16 {
        get{
            let current = _timestamp
            _timestamp = _timestamp + 1
            return current
        }
    }
    private var mNetworkResponse:LPBleNetworkResponse?
    private var mOnNetworkListComplete:(([LPBleSensorNode]?)->())?
    private var mOnSensorNodeRequestComplete:((Data)->())?
    private var mOnNetworkTopologyRequestComplete:((NetworkTopology?)->())?;
    private var mOnChangeLedDimmingRequestComplete:((ChangeActuatorStateResponseParser.ActuatorState?)->())?
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        if let response = mNetworkResponse{
            response.append(data: data)
            if(response.isComplete()){
                stopTimer()
                let payload = response.getPayload()!
                let commandId = CommandId(rawValue:response.getCommandId()!)
                //set to nil the response to be able to post a new command from a callback
                mNetworkResponse=nil
                parentNode.disableNotification(self)
                if let id = commandId{
                switch(id){
                    case .getNodeList:
                        let nodes = GetNodeListResponseParser.parse(payload)
                        mOnNetworkListComplete?(nodes)
                        mOnNetworkListComplete=nil
                        break
                    case .getNodeSensorValue:
                        mOnSensorNodeRequestComplete?(payload)
                        mOnSensorNodeRequestComplete = nil
                        break;
                    case .getNetworkTopology:
                        let topology = GetNetworkTopologyResponseParser.parse(payload)
                        mOnNetworkTopologyRequestComplete?(topology)
                        mOnNetworkTopologyRequestComplete = nil
                        break;
                    case .changeActuatorState:
                        let actuatorState = ChangeActuatorStateResponseParser.parse(payload)
                        mOnChangeLedDimmingRequestComplete?(actuatorState)
                        mOnChangeLedDimmingRequestComplete=nil
                        break;
                    }//switch
                }//if command
            }//is complete
        }
        
        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: []),
                                      nReadData: UInt32(data.count))
    }
    

    
    public func getNetworkNodeList(onComplete:@escaping ([LPBleSensorNode]?)->()) ->Bool{
        guard mNetworkResponse==nil else{
            return false
        }
    
        let request = LPBleNetworkRequest(timestamp: timestamp,
                                          commandId: CommandId.getNodeList.rawValue,
                                          payload: nil)
        
        mOnNetworkListComplete = onComplete
        mNetworkResponse = LPBleNetworkResponse()
        parentNode.enableNotification(self)
        startCommandTimeout { [weak self] in
            onComplete(nil)
            self?.mOnNetworkListComplete=nil
        }
        
        write(request.getData())
        return true
    }
    
    public func getNodeSensorData(node:LPBleNetworkAddress,
                                  onComplete:@escaping (LPBleSensorNode?)->())->Bool{
        
        guard mNetworkResponse==nil else{
            return false
        }
        
        let request = LPBleNetworkRequest(timestamp: timestamp,
                                          commandId: CommandId.getNodeSensorValue.rawValue,
                                          payload: node.bytes)
        
        mOnSensorNodeRequestComplete = { (data:Data) in
            onComplete(GetNodeSensorResponseParser.parse(data: data, from: node))
        }
        
        mNetworkResponse = LPBleNetworkResponse()
        parentNode.enableNotification(self)
        startCommandTimeout { [weak self] in
            onComplete(nil)
            self?.mOnSensorNodeRequestComplete=nil
        }
        write(request.getData())
        return true
    }
    
    public func getNetworkTopology(onComplete:@escaping (NetworkTopology?)->())->Bool{
        guard mNetworkResponse==nil else{
            return false
        }
        
        let request = LPBleNetworkRequest(timestamp: timestamp,
                                          commandId: CommandId.getNetworkTopology.rawValue,
                                          payload:nil)
        mOnNetworkTopologyRequestComplete = onComplete
        mNetworkResponse = LPBleNetworkResponse()
        parentNode.enableNotification(self)
        
        startCommandTimeout { [weak self] in
            onComplete(nil)
            self?.mOnNetworkTopologyRequestComplete=nil
        }
        
        write(request.getData())
        return true
    }
    
    private var timer: DispatchSourceTimer?
    
    private func startCommandTimeout( onFired:@escaping ()->Void){
        
        timer = DispatchSource.makeTimerSource(queue: mTimeoutQueue)
        timer?.scheduleOneshot(deadline: .now() + Feature6LoWPANProtocol.COMMAND_TIMEOUT)
        timer?.setEventHandler{ [weak self] in
            onFired()
            self?.parentNode.disableNotification(self!)
            self?.mNetworkResponse=nil
        }
        timer?.resume()
    }
    
    private func stopTimer(){
        timer?.cancel()
        timer = nil
    }
    
    private static let LED_ACTUATOR_ID = UInt8(0x10)
    
    public func updateLedDimming(address:LPBleNetworkAddress, dimingValue:UInt8,
                                 onCompete:@escaping (LPBleNetworkAddress,UInt8?)->())->Bool{
        guard mNetworkResponse==nil else{
            return false
        }
        
        var payload = Data()
        payload.append(address.bytes)
        payload.append(Feature6LoWPANProtocol.LED_ACTUATOR_ID)
        payload.append(dimingValue)
        mNetworkResponse = LPBleNetworkResponse()
        let request = LPBleNetworkRequest(timestamp: timestamp,
                                          commandId: CommandId.changeActuatorState.rawValue,
                                          payload: payload)
        
        mOnChangeLedDimmingRequestComplete = { newState in
            if let state = newState{
                if(address.getShortAddres() == state.nodeShortAddr ||
                    address == LPBleNetworkAddress.BROADCAST_ADDRESS){
                    onCompete(address,state.actuatorValue)
                    return;
                }//if address
            }// if let
            // if new state is nil or address is not correct there is an error
            onCompete(address,nil);
        }
        
        parentNode.enableNotification(self)
        startCommandTimeout { [weak self] in
            self?.mOnChangeLedDimmingRequestComplete?(nil)
            self?.mOnChangeLedDimmingRequestComplete=nil
        }
        write(request.getData())
        return true;
    }
    
}
