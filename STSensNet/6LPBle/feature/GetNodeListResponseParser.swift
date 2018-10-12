//
//  GetNodeListResponseParser.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 29/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation
class GetNodeListResponseParser{

    public static func parse(_ payload:Data) -> [LPBleSensorNode]?{
        let nNode = Int(payload[0])
        guard payload.count == 1+8*nNode else {
            return nil
        }
        return (0..<nNode).compactMap{index in
            let startAddress = 1+LPBleNetworkAddress.ADDRESS_LENGTH*index
            let endAddress = startAddress + LPBleNetworkAddress.ADDRESS_LENGTH
            if let address = LPBleNetworkAddress(payload.subdata(in: startAddress..<endAddress)){
                return LPBleSensorNode(address: address)
            }else{
                return nil
            }
        }
    }

    
}
