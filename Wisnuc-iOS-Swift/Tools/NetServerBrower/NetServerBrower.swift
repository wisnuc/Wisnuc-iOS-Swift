//
//  NetServerBrower.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Foundation

@objc protocol NetServerBrowerForLogDelegate {
    func serverBrowserFoundService(service:NetService)
    func serverBrowserLostService(service:NetService,index:Int)
    func serviceDidStop(service:NetService)
}

class NetServerBrower: NSObject,NetServiceDelegate{
    var _serverType:String?
    var _port:__int64_t?
    var netServerBrower:NetServiceBrowser!
    var discoveredServers:[NetService]?
    var resolvedServers:[NetService]?
    weak var delegate:NetServerBrowerForLogDelegate?
    
    init( type: String, port: __int64_t) {
        super.init()
        _serverType = type
        _port = port
        netServerBrower = NetServiceBrowser.init()
        netServerBrower.delegate = self
        netServerBrower.searchForServices(ofType: type, inDomain: "local.")
        discoveredServers = Array.init()
        resolvedServers = Array.init()
    }
    
    deinit {
        stopServerBrowser()
        netServerBrower?.delegate = nil
        for num in (discoveredServers?.enumerated())!{
            num.element.delegate = nil
        }
        netServerBrower = nil
    }
    
    func stopServerBrowser(){
        netServerBrower.stop()
    }
    
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        resolvedServers?.append(sender)
        if let delegateOK = self.delegate {
            delegateOK.serverBrowserFoundService(service: sender)
        }
    }
}

extension NetServerBrower:NetServiceBrowserDelegate{
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        discoveredServers?.append(service)
        service.resolve(withTimeout: 6)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        let index = discoveredServers?.index(of: service)
        service.delegate = nil
        if index != nil {
            discoveredServers?.remove(at:index!)
        }
        let indexResolved = resolvedServers?.index(of: service)
        if indexResolved != nil {
            resolvedServers?.remove(at:indexResolved!)
        }
        if let delegateOK = self.delegate {
            delegateOK.serverBrowserLostService(service: service, index: index!)
        }
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        let index:Int? = discoveredServers?.index(of: sender)
        let indexResolved = resolvedServers?.index(of: sender)
        if index != nil {
            discoveredServers?.remove(at: index!)
        }
        
        if indexResolved != nil {
            resolvedServers?.remove(at: indexResolved!)
        }
    }
    
    func netServiceDidStop(_ sender: NetService) {
        if let delegateOK = self.delegate {
            delegateOK.serviceDidStop(service: sender)
        }
    }
}
