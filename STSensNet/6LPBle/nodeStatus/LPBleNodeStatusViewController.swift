//
//  LPBleNodeStatusViewController.swift
//  STSensNet
//
//  Created by Giovanni Visentini on 24/05/2018.
//  Copyright © 2018 STCentralLab. All rights reserved.
//

import Foundation

public class LPBleNodeStatusViewController : UITableViewController, LPBleNodeStatusView{
    
    private static let TEMPERATURE_FORMAT = "%.1f C"
    private static let PRESSURE_FORMAT = "%.1f mbar"
    private static let HUMIDITY_FORMAT = "%.1f %%"
    private static let ACCELEROMETER_FORMAT = "(x: %.0f, y: %.0f, z: %.0f) mG"
    private static let GYROSCOPE_FORMAT = "(x: %.1f, y: %.1f, z: %.1f) dps"
    private static let MAGNETOMETER_FORMAT = "(x: %.0f, y: %.0f, z: %.0f) mGa"
    private static let LED_FORMAT = "Dimming: %d"
    
    @IBOutlet weak var mNodeAddressLabel: UILabel!
    @IBOutlet weak var mTemperatureValue: UILabel!
    @IBOutlet weak var mPressureValue: UILabel!
    @IBOutlet weak var mHumidityValue: UILabel!
    @IBOutlet weak var mAccelerationValue: UILabel!
    @IBOutlet weak var mMagnetometerValue: UILabel!
    @IBOutlet weak var mGyroscopeValue: UILabel!
    
    public var nodeAddress:LPBleNetworkAddress!
    public var centraNode:Feature6LoWPANProtocol!
    
    private var mPresenter:LPBleNodeStatusPresenter?
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mPresenter = LPBleNodeStatusPresenterImpl(view: self,centralNode: centraNode, nodeAddress:nodeAddress)
        mPresenter?.startRetrievingSensorData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mPresenter?.stopRetrievingSensorData()
    }
    
    func showNodeAddress(_ address: LPBleNetworkAddress) {
        DispatchQueue.main.async {
            self.mNodeAddressLabel.text=address.description
        }
    }
    
    func showTemperature(_ temperature: Float) {
        DispatchQueue.main.async {
            self.mTemperatureValue.text = String(format:LPBleNodeStatusViewController.TEMPERATURE_FORMAT,temperature)
        }
    }
    
    func showPressure(_ pressure: Float) {
        DispatchQueue.main.async {
            self.mPressureValue.text = String(format:LPBleNodeStatusViewController.PRESSURE_FORMAT,pressure)
        }
    }
    
    func showHumidity(_ humidity: Float) {
        DispatchQueue.main.async {
            self.mHumidityValue.text = String(format:LPBleNodeStatusViewController.HUMIDITY_FORMAT,humidity)
        }
    }
    
    func showAccelerometer(x: Float, y: Float, z: Float) {
        DispatchQueue.main.async {
            self.mAccelerationValue.text = String(format:LPBleNodeStatusViewController.ACCELEROMETER_FORMAT,x,y,z)
        }
    }
    
    func showGyroscope(x: Float, y: Float, z: Float) {
        DispatchQueue.main.async {
            self.mGyroscopeValue.text = String(format:LPBleNodeStatusViewController.GYROSCOPE_FORMAT,x,y,z)
        }
    }
    
    func showMagnetometer(x: Float, y: Float, z: Float) {
        DispatchQueue.main.async {
            self.mMagnetometerValue.text = String(format:LPBleNodeStatusViewController.MAGNETOMETER_FORMAT,x,y,z)
        }
    }
    
    func showInvalidResponseError() {
        DispatchQueue.main.async {
            self.showAllert(title: "Invalid response", message: "Command error")
        }
    }
    
    @IBOutlet weak var mLedCell: UITableViewCell!
    @IBOutlet weak var mLedImage: UIImageView!
    @IBOutlet weak var mLedValue: UILabel!
    
    func showLedStatus(dimmingValue: UInt8) {
        DispatchQueue.main.async {
            self.mLedCell.isHidden = false;
            self.mLedValue.text = String(format:LPBleNodeStatusViewController.LED_FORMAT,dimmingValue)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onLedDimmingChange(_ sender: UIStepper) {
        if (sender.value == 0.0){
            mLedImage.image = #imageLiteral(resourceName: "led_off_small")
        }else{
            mLedImage.image = #imageLiteral(resourceName: "led_on_small")
        }
        mPresenter?.setLedDimmingStatus(dimmingValue: UInt8(sender.value))
    }
    
    
}
