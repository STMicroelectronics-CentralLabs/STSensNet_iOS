//
//  LPBleNetworkTopologyContract.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 25/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

struct LPBleNetworkNodeData{
    let address:String
    let routeToRoot:[String]
}

protocol LPBleNetworkTopologyView:class {
    func showNodes(_ nodes:[LPBleNetworkNodeData])
    func showInvalidResponseError()
}

protocol LPBleNetworkTopologyPresenter:class {
    func requestNodeTopology()
}
