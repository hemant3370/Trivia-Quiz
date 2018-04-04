//
//  TVAPI.swift
//  Zillious
//
//  Created by Hemant Singh on 29/06/17.
//  Copyright © 2017 Zillious Solutions. All rights reserved.

import Foundation
import Moya
import Alamofire

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}
let configuration = { () -> URLSessionConfiguration in
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    config.timeoutIntervalForRequest = 200 // as seconds, you can set your request timeout
    config.timeoutIntervalForResource = 400 // as seconds, you can set your resource timeout
    config.requestCachePolicy = .useProtocolCachePolicy
    return config
}()
let manager = Manager(
    configuration: configuration,
    serverTrustPolicyManager: CustomServerTrustPoliceManager()
)
let TVAPIProvider = MoyaProvider<Travolution>(manager: manager,plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter), LoaderPlugin()])

// MARK: - Provider support

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum Travolution {
    case CREATETOKEN
    case REFRESHTOKEN([String: Any])
    case GETCATEGORIES
    case GETQUIZ([String: Any])
}

extension Travolution: TargetType {
    
    public var task: Task {
        switch self {
        case .CREATETOKEN:
            return .requestParameters(parameters: ["command": "request"], encoding: URLEncoding.queryString)
        case .REFRESHTOKEN(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .GETQUIZ(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return [:]
    }

    public var baseURL: URL { return URL(string: "https://opentdb.com")! }
   
    public var path: String {
        switch self {
        case .GETQUIZ:
            return "/api.php"
        case .CREATETOKEN,
             .REFRESHTOKEN:
            return "api_token.php"
        case .GETCATEGORIES:
            return "/api_category.php"
        }
    }
    public var method: Moya.Method {
        return .get
    }
    
   var parameterEncoding: ParameterEncoding {
        return URLEncoding.queryString
    }
    
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    public var sampleData: Data {
            return "{}".data(using: String.Encoding.utf8)!
    }
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

//MARK: - Response Handlers

extension Moya.Response {
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
}

class CustomServerTrustPoliceManager : ServerTrustPolicyManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return .disableEvaluation
    }
    public init() {
        super.init(policies: [:])
    }
}
