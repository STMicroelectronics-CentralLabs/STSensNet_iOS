
import Foundation

protocol LPBleNetworkStatusView : class {
    func showNodes(_ nodes:[LPBleSensorNode])
    func showNodeDetails(_ node:LPBleSensorNode)
    func showInvalidResponseError()
}

protocol LPBleNetworkStatusPresenter : class{
    func startNodeRefresh()
    func stopNodeRefresh()
    func getNodes();
    func onNodeSelected(_ node:LPBleSensorNode)
}
