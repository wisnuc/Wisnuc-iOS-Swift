//
//  NetServerBrower.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Foundation

protocol NetServerBrowerForLogDelegate {
    func serverBrowserFoundService(service:NetService)
    func serverBrowserLostService(service:NetService,index:Int)
}

class NetServerBrower: NSObject,NetServiceBrowserDelegate,NetServiceDelegate{
    var _serverType:String?
    var _port:__int64_t?
    var _netServerBrower:NetServiceBrowser!
    var _discoveredServers:[NetService]?
    var _resolvedServers:[NetService]?
    var delegate:NetServerBrowerForLogDelegate?
    
    init( type: String, port: __int64_t) {
        super.init()
        _serverType = type
        _port = port
        _netServerBrower = NetServiceBrowser.init()
        _netServerBrower.delegate = self
        _netServerBrower.searchForServices(ofType: type, inDomain: "local.")
        _discoveredServers = Array.init()
        _resolvedServers = Array.init()
    }
    
    deinit {
        stopServerBrowser()
        _netServerBrower?.delegate = nil
        for num in (_discoveredServers?.enumerated())!{
            num.element.delegate = nil
        }
        _netServerBrower = nil
    }
    
    func stopServerBrowser(){
        _netServerBrower.stop()
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        _discoveredServers?.append(service)
        service.resolve(withTimeout: 6)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        let index = _discoveredServers?.index(of: service)
        service.delegate = nil
        if index != nil {
            _discoveredServers?.remove(at:index!)
        }
        let indexResolved = _resolvedServers?.index(of: service)
        if indexResolved != nil {
            _resolvedServers?.remove(at:indexResolved!)
        }
        delegate?.serverBrowserLostService(service: service, index: index!)
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        let index:Int? = _discoveredServers?.index(of: sender)
        let indexResolved = _resolvedServers?.index(of: sender)
        if index != nil {
            _discoveredServers?.remove(at: index!)
        }
        
        if indexResolved != nil {
            _resolvedServers?.remove(at: indexResolved!)
        }
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        _resolvedServers?.append(sender)
        delegate?.serverBrowserFoundService(service: sender)
    }
}

