//
//  LPBleNodeStatusContract.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 24/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

protocol LPBleNodeStatusView : class {
    func showNodeAddress(_ address:LPBleNetworkAddress)
    func showTemperature(_ temperature:Float)
    func showPressure(_ pressure:Float)
    func showHumidity(_ humidity:Float)
    func showAccelerometer(x:Float,y:Float,z:Float)
    func showGyroscope(x:Float,y:Float,z:Float)
    func showMagnetometer(x:Float,y:Float,z:Float)
    func showLedStatus(dimmingValue:UInt8)

    func showInvalidResponseError()
}

protocol LPBleNodeStatusPresenter : class{
    func startRetrievingSensorData()
    func stopRetrievingSensorData()
    func setLedDimmingStatus(dimmingValue:UInt8)
}
