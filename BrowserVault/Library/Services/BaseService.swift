//
//  BaseService.swift
//  Dating
//
//  Created by Hai Le on 5/24/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import UIKit
import Alamofire

typealias ServiceGenericBlock = (NetworkingResult, DataStatusEnum) -> ()

class BaseService {

    required init() {
        
    }
    
    static let shared = BaseService()
    
    public func request<T: BaseModel>(serviceParams: ServiceParams, parseJson: BlockParseJsonModel? = nil, mapJsonAt keyPath: String? = nil, completion: @escaping (T?, Error?) -> Void) where T: Decodable {
        Logger.debug("Request URL: \(serviceParams.requestURL.absoluteString)")
        
        var header: [String: String]!
        if serviceParams.requestHeader is SecurityHeader {
            header = (serviceParams.requestHeader as! SecurityHeader).headers
        } else {
            header = serviceParams.requestHeader.headers
        }
        
        Logger.debug("Headers: \(String(describing: header))")
        var request: DataRequest!
        
        let handerRequest = { (request: DataRequest) -> () in
            request.responseData { (response) in
                if response.result.isSuccess {
                    if let data = response.result.value {
                        do {
                            let resource: APIResource = APIResource(data: data)
                            if let parseJson = parseJson {
                                if let keyPath = keyPath, let json = ((try? resource.mapJSON()) as?  NSDictionary)?.value(forKeyPath: keyPath) as? [String: Any] {
                                    let result = parseJson(json)
                                    completion(result.0 as? T, result.1)
                                } else if let json = ((try? resource.mapJSON()) as?  [String: Any]) {
                                    let result = parseJson(json)
                                    completion(result.0 as? T, result.1)
                                } else {
                                    let result = try resource.map(to: T.self, atKeyPath: keyPath)
                                    completion(result, nil)
                                }
                            } else {
                                let result = try resource.map(to: T.self, atKeyPath: keyPath)
                                completion(result, nil)
                            }
                        } catch let error {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, response.result.error)
                }
            }
        }
        switch serviceParams.task {
        case .requestParameters(let params):
            request = Alamofire.request(serviceParams.requestURL, method: serviceParams.httpMethod, parameters: params, headers: header)
        case .requestParametersEncoding(let parameters, let encoding):
            request = Alamofire.request(serviceParams.requestURL, method: serviceParams.httpMethod, parameters: parameters, encoding: encoding, headers: header)
        case .uploadMultipart( let multipartBody):
            let multipartFormData: (RequestMultipartFormData) -> Void = { form in
                form.applyMoyaMultipartFormData(multipartBody)
            }
            Alamofire.upload( multipartFormData: multipartFormData,
                to: serviceParams.requestURL,
                method: serviceParams.httpMethod,
                headers: header,
                encodingCompletion: { result in
                    switch result {
                    case .success(let alamoRequest, _, _):
                        alamoRequest.uploadProgress(closure: { (progress) in
                            serviceParams.progressHandler?(progress)
                        })
                        handerRequest(alamoRequest)
                    case .failure(let error):
                        completion(nil, error)
                    }
            })
            return
        }
        handerRequest(request)
    }
    
    public func requestAny(serviceParams: ServiceParams, completion: @escaping (Any?, Error?) -> Void) {
        Logger.debug("Request URL: \(serviceParams.requestURL.absoluteString)")
        
        var header: [String: String]!
        if serviceParams.requestHeader is SecurityHeader {
            header = (serviceParams.requestHeader as! SecurityHeader).headers
        } else {
            header = serviceParams.requestHeader.headers
        }
        Logger.debug("Headers: \(String(describing: header))")
        var request: DataRequest!
        let handerRequest = { (request: DataRequest) -> () in
            request.responseData { (response) in
                if response.result.isSuccess {
                    if let data = response.result.value {
                        completion(data, nil)
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, response.result.error)
                }
            }
        }
        switch serviceParams.task {
        case .requestParameters(let params):
            request = Alamofire.request(serviceParams.requestURL, method: serviceParams.httpMethod, parameters: params, headers: header)
        case .requestParametersEncoding(let parameters, let encoding):
            request = Alamofire.request(serviceParams.requestURL, method: serviceParams.httpMethod, parameters: parameters, encoding: encoding, headers: header)
        case .uploadMultipart( let multipartBody):
            let multipartFormData: (RequestMultipartFormData) -> Void = { form in
                form.applyMoyaMultipartFormData(multipartBody)
            }
            Alamofire.upload( multipartFormData: multipartFormData,
                              to: serviceParams.requestURL,
                              method: serviceParams.httpMethod,
                              headers: header,
                              encodingCompletion: { result in
                                switch result {
                                case .success(let alamoRequest, _, _):
                                    alamoRequest.uploadProgress(closure: { (progress) in
                                        serviceParams.progressHandler?(progress)
                                    })
                                    handerRequest(alamoRequest)
                                case .failure(let error):
                                    completion(nil, error)
                                }
            })
            return
        }
        handerRequest(request)
    }

    public func requestArray<T: BaseModel>(serviceParams: ServiceParams, parseJson: BlockParseJsonArrayModel? = nil, completion: @escaping ([T]?, Error?) -> Void) where T: Decodable {
        Logger.debug("Request URL: \(serviceParams.requestURL.absoluteString)")
        
        var header: [String: String]!
        if serviceParams.requestHeader is SecurityHeader {
            header = (serviceParams.requestHeader as! SecurityHeader).headers
        } else {
            header = serviceParams.requestHeader.headers
        }
        Logger.debug("Headers: \(String(describing: header))")
        var request: DataRequest!
        let handerRequest = { (request: DataRequest) -> () in
            request.responseData { (response) in
                if response.result.isSuccess {
                    if let data = response.result.value {
                        let resource: APIResource = APIResource(data: data)
                        if let parseJson = parseJson {
                            if let json = ((try? resource.mapJSON()) as?  [[String: Any]]) {
                                let result = parseJson(json)
                                completion(result.0 as? [T], result.1)
                            } else {
                                let result = try? resource.map(to: [T].self)
                                completion(result, nil)
                            }
                        } else {
                            let result = try? resource.map(to: [T].self)
                            completion(result, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, response.result.error)
                }
            }
        }
        switch serviceParams.task {
        case .requestParameters(let params):
            request = Alamofire.request(serviceParams.requestURL, method: serviceParams.httpMethod, parameters: params, headers: header)
        case .requestParametersEncoding(let parameters, let encoding):
            request = Alamofire.request(serviceParams.requestURL, method: serviceParams.httpMethod, parameters: parameters, encoding: encoding, headers: header)
        case .uploadMultipart( let multipartBody):
            let multipartFormData: (RequestMultipartFormData) -> Void = { form in
                form.applyMoyaMultipartFormData(multipartBody)
            }
            Alamofire.upload( multipartFormData: multipartFormData,
                              to: serviceParams.requestURL,
                              method: serviceParams.httpMethod,
                              headers: header,
                              encodingCompletion: { result in
                                switch result {
                                case .success(let alamoRequest, _, _):
                                    alamoRequest.uploadProgress(closure: { (progress) in
                                        serviceParams.progressHandler?(progress)
                                    })
                                    handerRequest(alamoRequest)
                                case .failure(let error):
                                    completion(nil, error)
                                }
            }
            )
            return
        }
        handerRequest(request)
    }
    
    func fetchDBByFilter<T: BaseModel>(_ filter: ServiceFilter<T>, completionBlock: @escaping (T?, Error?) -> ()) where T: Decodable {
        if let predicate = filter.predicate, let modelPredicate = ModelMgr.fetchObject(filter.modelType, filter: predicate) {
            completionBlock(modelPredicate, nil)
        } else if let model = ModelMgr.fetchObject(filter.modelType) {
            completionBlock(model, nil)
        } else {
            completionBlock(nil, CustomError.unknown)
        }
    }
    
    func submitRequestToServerWithFilter<T: BaseModel>(_ filter: ServiceFilter<T>, params:ServiceParams, completionBlock:  @escaping (T?, Error?) -> ()) where T: Decodable {
        self.request(serviceParams: params, completion: completionBlock)
    }
    
    func handleServiceResult<T: BaseModel>(_ serviceResult: (T?, Error?), dataStatus: DataStatusEnum, completionBlock: ServiceGenericBlock?) {
        var networkResult: NetworkingResult
        if let result = serviceResult.0 {
            networkResult = NetworkingResult(object: result)
            
        } else if let error = serviceResult.1 {
            networkResult = NetworkingResult(object: nil)
            networkResult.error = error
        } else {
            networkResult = NetworkingResult(object: nil)
            networkResult.error = CustomError.unknown
        }
        completionBlock?(networkResult, dataStatus)
    }
    
    func callServerWithFilter<T: BaseModel>(_ filter: ServiceFilter<T>, params:ServiceParams, completionBlock: ServiceGenericBlock?) where T: Decodable {
        switch filter.cachedPolicy {
        case .cachePolicyNWOnly:
            submitRequestToServerWithFilter(filter, params: params) { (result, error) in
                self.handleServiceResult((result,error), dataStatus: .dataStatusFromServer, completionBlock: completionBlock)
            }
        case .cachePolicyDBThenNW:
            fetchDBByFilter(filter) { (result, error) in
                self.handleServiceResult((result,error), dataStatus: .dataStatusFromDB, completionBlock: completionBlock)
            }
            submitRequestToServerWithFilter(filter, params: params) { (result, error) in
                self.handleServiceResult((result,error), dataStatus: .dataStatusFromServer, completionBlock: completionBlock)
            }
        default:
            fetchDBByFilter(filter) { (result, error) in
                self.handleServiceResult((result,error), dataStatus: .dataStatusFromDB, completionBlock: completionBlock)
            }
            break
        }
    }

}
