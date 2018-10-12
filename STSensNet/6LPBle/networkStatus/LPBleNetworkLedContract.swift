//
//  LPBleNetworkLedSetatusContract.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 04/06/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

protocol LPBleNetworkLedView : class {
    func showSwitchAllOn()
    func showSwitchAllOff()
    func showSwitchUpdateFail()
}

protocol LPBleNetworkLedPresenter : class{
    func switchAllOn();
    func switchAllOff();
}


