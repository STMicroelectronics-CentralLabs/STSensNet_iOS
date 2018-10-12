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
import UIKit

import BlueSTSDK_Gui

public class MainViewController : UINavigationController{

    private static let DID_RUN_BEFORE = "STSensNet.BleStarVersionDialog.didRunBefore"
    fileprivate static let BLESTAR1_NODE_ID = UInt8(0x81)
    fileprivate static let SIXLPBLE_NODE_ID = UInt8(0x8B)
    
    private func onDismisInfoDialog(){
        let settings = UserDefaults.standard
        settings.set(true, forKey: MainViewController.DID_RUN_BEFORE)
        settings.synchronize()
    }
    
    private func needToShowInfoDialog()->Bool{
        return !UserDefaults.standard.bool(forKey: MainViewController.DID_RUN_BEFORE)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let storyBoard = UIStoryboard(name: "BlueSTSDKMainView",
                                      bundle: Bundle(for:BlueSTSDKMainViewController.self))
        let mainView = storyBoard.instantiateInitialViewController() as? BlueSTSDKMainViewController
        mainView?.delegateAbout = self;
        mainView?.delegateNodeList = self;
        mainView?.delegateMain=nil;
        
        registerBleStarCharacteristics()
        register6LPoWANBleCharacteristics()
        
        pushViewController(mainView!, animated: true)
    }
    
    private func registerBleStarCharacteristics(){
        
        let charMap = [
            0x00080000 : STSensNetGenericRemoteFeature.self,
            0x00040000 : STSensNetCommandFeature.self
        ]
        BlueSTSDKManager.sharedInstance()
            .addFeature(forNode: MainViewController.BLESTAR1_NODE_ID,
                        features: charMap)
    }
    
    private func register6LPoWANBleCharacteristics(){
        let charMap = [
            0x00020000 : Feature6LoWPANProtocol.self,
        ]
        BlueSTSDKManager.sharedInstance()
            .addFeature(forNode: MainViewController.SIXLPBLE_NODE_ID,
                        features: charMap)
    }
    
}

extension MainViewController : BlueSTSDKAboutViewControllerDelegate{
    public func abaoutHtmlPagePath() -> String? {
        return Bundle.main.path(forResource: "text", ofType: "html")
    }
    
    public func headImage() -> UIImage? {
        return #imageLiteral(resourceName: "press_contact.jpg")
    }
    
    public func privacyInfoUrl() -> URL? {
        return URL(string: "http://www.st.com/content/st_com/en/common/privacy-policy.html")
    }
    
    public func libLicenseInfo() -> [BlueSTSDKLibLicense]? {
        let bundle = Bundle.main;
        return [
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK_Gui", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "MBProgressHUD", ofType: "txt")!),
        ]
    }
    
}


extension MainViewController : BlueSTSDKNodeListViewControllerDelegate{   
    
    private func isBleStarNode(_ node:BlueSTSDKNode) ->Bool{
        return node.type == .nucleo &&
            node.typeId == MainViewController.BLESTAR1_NODE_ID
    }
    
    private func is6LowPWANNode(_ node:BlueSTSDKNode)-> Bool{
        return (node.type == .nucleo &&
                node.typeId == MainViewController.SIXLPBLE_NODE_ID)
    }
    
    private func isSTM32WBNode(_ node:BlueSTSDKNode)-> Bool{
        return STM32WBPeer2PeerDemoConfiguration.isValidNode(node)
    }
    
    public func display(node: BlueSTSDKNode) -> Bool {
        return isBleStarNode(node) || is6LowPWANNode(node) || isSTM32WBNode(node);
    }
    
    private func start6LoWPANDemoWithNode(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController{
        let storyBoard = UIStoryboard(name: "6LPBleStoryboard", bundle: nil)
        let demoView = storyBoard.instantiateInitialViewController() as? LPBleNetworkStatusViewController
        demoView?.node = node
        demoView?.menuDelegate=menuManager
        return demoView!
    }
    
    private func startSTM32WBDemoWithNode(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController{
        let p2pDemoBoudle = Bundle(for: STM32WBRSSIUpdateViewController.self)
        let storyBoard = UIStoryboard(name: "STM32WB_P2PDemo", bundle: p2pDemoBoudle)
        let demoID = node.typeId == STM32WBPeer2PeerDemoConfiguration.WB_ROUTER_NODE_ID ? "STM32WBLedNetworkViewController" : "STM32WBLedButtonViewController"
        let demoView = storyBoard.instantiateViewController(withIdentifier: demoID) as? STM32WBRSSIUpdateViewController
        demoView?.node = node
        demoView?.menuDelegate=menuManager
        return demoView!
    }
    
    private func startBleStarDemoWithNode(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController{
        let storyBoard = UIStoryboard(name: "BleStarStoryboard", bundle: nil)
        let demoView = storyBoard.instantiateInitialViewController() as? GenericRemoteNodeTableViewController
        demoView?.node = node
        demoView?.menuDelegate = menuManager
        return demoView!
    }

    
    public func prepareToConnect(node: BlueSTSDKNode) {
        if(isSTM32WBNode(node)){
    node.addExternalCharacteristics(STM32WBPeer2PeerDemoConfiguration.getCharacteristicMapping());
        }
    }
    
    public func demoViewController(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController{
        
        if(is6LowPWANNode(node)){
            return start6LoWPANDemoWithNode(with: node, menuManager: menuManager)
        }else if(isBleStarNode(node)){
            return startBleStarDemoWithNode(with: node, menuManager: menuManager)
        }else if(isSTM32WBNode(node)){
            return startSTM32WBDemoWithNode(with: node, menuManager: menuManager)
        }
        // the node is filter by the display function
        // the defaut case will never run
        return self
    }
}
