//
//  KPSocketManager.swift
//  Housie
//
//  Created by Pravin-M004 on 10/23/20.
//  Copyright © 2020 Yudiz. All rights reserved.
//

import UIKit
import SocketIO

// MARK: - Enum Error
enum MyError : Error {
    case runtimeError(String)
    var errDesc: String {
        if case let .runtimeError(str) = self {
            return str
        } else {
            return ""
        }
    }
}

// MARK: - Enum Socket Event
enum SocketEventResponse: String {
    case getMiningTransactionHistoryResponse = "getMiningTransactionHistoryResponse"
    case getTeamsResponse = "getTeamsResponse"
    case get_mingin_balance_response = "get_mingin_balance_response"
    case startMiningResponse = "startMiningResponse"
    case getNewsResponse = "getNewsResponse"
}



// MARK: - Enum Socket Event
enum SocketEvent: String {
    case getMiningTransactionHistory = "getMiningTransactionHistory"
    case getTeams = "getTeams"
    case get_mingin_balance = "get_mingin_balance"
    case startMining = "startMining"
    case getNews = "getNews"
}

typealias CompBlock = (_ json: Any?, _ error: MyError?) -> ()
typealias listnerEventCall = (SocketEventResponse, Any?) -> ()
typealias StatusChCall = (SocketIOStatus) -> ()

// MARK: - Class KPSocketManager
class KPSocketManager {
    
    private lazy var manager: SocketManager = {
        let dict: [String: Any] =  [:]
        return SocketManager(socketURL: URL(string: YZAPIMode.socketBasePath())!, config: SocketIOClientConfiguration(arrayLiteral: .forceNew(true), .log(false), .reconnectWait(3)))
    }()
    private lazy var socket: SocketIOClient = {
        return manager.defaultSocket
    }()
    
    var connectionStatus: SocketIOStatus {
        return socket.status
    }
    var listnerCall: listnerEventCall?
    var statusCHCall: StatusChCall?
    
    init() {
        addConnectionListner()
        
    }
    
    deinit {
        _defaultCenter.removeObserver(self)
        yzPrint(items: "Deallocated: KPSocketManager")
    }
    
    func connectSockect() {
        socket.connect(timeoutAfter: 0) { [weak self] in
            guard let _ = self else { return }
            yzPrint(items: "------- Socket Connected -------")
        }
    }
    
    func disConnect() {
        socket.disconnect()
        yzPrint(items: "------- Socket Disconnected -------")
    }
}

// MARK:- Listner Methods
extension KPSocketManager {
    
    private func addConnectionListner() {
        dataListner()
        statusListner()
    }
    
    private func statusListner() {
        socket.on(clientEvent: SocketClientEvent.connect) { [weak self] (obj, ack) in
            guard let _ = self else { return }
            yzPrint(items: "------ Socket Conntected: \n\(obj) ------")
        }
        
        socket.on(clientEvent: SocketClientEvent.error) { [weak self] (obj, ack) in
            guard let _ = self else { return }
            yzPrint(items: "--------- Socket Error: \n\(obj) ----------")
        }
        
        socket.on(clientEvent: SocketClientEvent.disconnect) { [weak self] (obj, ack) in
            guard let _ = self else { return }
            yzPrint(items: "--------- Socket Disconnected: \n\(obj) ---------")
        }
        
        socket.on(clientEvent: SocketClientEvent.statusChange) { [weak self] (obj, ack) in
            guard let weakSelf = self else { return }
            weakSelf.statusCHCall?(weakSelf.socket.status)
        }
        
//        socket.onAny { (socketEvent) in
//            yzPrint(items: "======================= Observer \(socketEvent.event) ==============================")
//            yzPrint(items: socketEvent.event)
//        }
    }
    
    private func dataListner() {
        
        socket.on(SocketEventResponse.getMiningTransactionHistoryResponse.rawValue + YZApp.shared.objLogInUser!.id) {[weak self] (data, emiter) in
            guard let weakSelf = self else { return }
//            yzPrint(items: "--- Socket received getMiningTransactionHistory: \nData: \(data) \nEmiter: \(emiter) ---")
            weakSelf.listnerCall?(SocketEventResponse.getMiningTransactionHistoryResponse, data)
        }
        
        socket.on(SocketEventResponse.getTeamsResponse.rawValue + YZApp.shared.objLogInUser!.id) {[weak self] (data, emiter) in
            guard let weakSelf = self else { return }
//            yzPrint(items: "--- Socket getTeams: \nData: \(data) \nEmiter: \(emiter) ---")
            weakSelf.listnerCall?(SocketEventResponse.getTeamsResponse, data)
        }
        
        socket.on(SocketEventResponse.get_mingin_balance_response.rawValue + YZApp.shared.objLogInUser!.id) {[weak self] (data, emiter) in
            guard let weakSelf = self else { return }
            yzPrint(items: "--- Socket get_mingin_balance: \nData: \(data) \nEmiter: \(emiter) ---")
            weakSelf.listnerCall?(SocketEventResponse.get_mingin_balance_response, data)
        }
        
        socket.on(SocketEventResponse.getNewsResponse.rawValue) {[weak self] (data, emiter) in
            guard let weakSelf = self else { return }
//            yzPrint(items: "--- Socket getNews: \nData: \(data) \nEmiter: \(emiter) ---")
            weakSelf.listnerCall?(SocketEventResponse.getNewsResponse, data)
        }
        
        socket.on(SocketEventResponse.startMiningResponse.rawValue + YZApp.shared.objLogInUser!.id) {[weak self] (data, emiter) in
            guard let weakSelf = self else { return }
//            yzPrint(items: "--- Socket startMiningResponse: \nData: \(data) \nEmiter: \(emiter) ---")
            weakSelf.listnerCall?(SocketEventResponse.startMiningResponse, data)
        }
    }
}

// MARK: - Emit Methods
extension KPSocketManager {
    

    
    func send(event: SocketEvent, param: [String: Any]) {
        self.emitWitAck(channel: event.rawValue, param: param) { Data, Error in
            
        }
    }
    
    func send(event: SocketEvent, stringParam: String) {
        emit(channel: event.rawValue, stringParam: stringParam)
    }
    
    private func emit(channel: String, param: [String: Any]) {
        yzPrint(items: "--- Socket Emit \nChannel: \(channel) param: \(param) ---")
        socket.emit(channel, param)
    }
    
    private func emit(channel: String, stringParam: String) {
        yzPrint(items: "--- Socket Emit \nChannel: \(channel) stringParam: \(stringParam) ---")
        socket.emit(channel, stringParam)
    }
    
    private func emitWitAck(channel: String, param: [String: Any], block: @escaping CompBlock) {
        yzPrint(items: "--- Socket Emit \nChannel: \(channel) param: \(param) ---")
        if socket.status == .connected {
            socket.emitWithAck(channel, with: [param]).timingOut(after: 1, callback: { [weak self] (data) in
                guard let _ = self else { return }
                if data.count == 2 && ((data.first as? NSNull) != nil) {
                    block(data[1], nil)
                } else {
                    if let errStr = data.first as? String {
                        block(nil, MyError.runtimeError(errStr))
                    } else {
                        block(nil, MyError.runtimeError("Internal Error \(channel)"))
                    }
                }
            })
        } else {
            self.connectSockect()
            block(nil, nil)
        }
    }
}
