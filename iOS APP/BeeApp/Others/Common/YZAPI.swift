//
//  YZAPI.swift
//


import Foundation
import Alamofire

//MARK: - Enumeration APIMessageFor
enum APIMessageFor {
    case success
    case error
}

enum APIResultStatus {
    case noData, failed, success, isLoading, locationFailed
}


/*
 Success - 200
 Already exist - 409
 something wrong - 405
 Not found /disabled/inactive/deleted- 404
 Unauthorised/login failed - 401
 Save failed/ error on server - 500
 Input data Validation error - 400
 Expectation Failed  / update etc - 417
 Connected to WIFI but no internet connection - 13
 User cancelled request - 15
 
 -1001 = Request time out
 -1009 = No Internet Connection.
 */

//MARK: - YZAPIMode
enum YZAPIMode {
    case local
    case development
    case live
    
    //Current API mode
    static var current: YZAPIMode = .live
    
    /// Current API Base URL
    ///
    /// - Parameter mode: Current API mode
    /// - Returns: URL in string depending on mode type
    static func apiBasePath(_ mode: YZAPIMode = current) -> String {
        if mode == .local {
            return "" //Developer/Machin LOCAL NETWORK URL
        }else if mode == .development {
            return "https://hbcu.presslayouts.com/hb/api/" //Development/Staging SERVER URL
        }else {
            return "https://hbcucrypto.com/admin/api/" //Production/Live SERVER URL
        }
    }
    
    /// Current Socket Base URL
    ///
    /// - Parameter mode: Current API mode
    /// - Returns: URL in string depending on mode type
    static func socketBasePath(_ mode: YZAPIMode = current) -> String {
        if mode == .local {
            return ""
        }else if mode == .development {
            return "http://hbcucrypto.com:3001"
        }else { //mode == .live
            return "http://hbcucrypto.com:3001" //Client live server
        }
    }
}

//MARK: - WSContentType
enum YZAPIContentType {
    case formData
    case formURLEncoded
    case applicationJSON
    var detail: HTTPHeaders {
        switch self {
        case .formData:
            var headers = HTTPHeaders.default
            headers.add(HTTPHeader(name: "Content-Type", value: "application/x-www-form-urlencoded"))
            return headers
        case .formURLEncoded:
            return HTTPHeaders([HTTPHeader(name: "Content-Type", value: "application/x-www-form-urlencoded"), HTTPHeader(name: "language", value: YZApp.shared.language.apiParameter)])
        case .applicationJSON:
            var headers = HTTPHeaders.default
            headers.add(HTTPHeader(name: "Content-Type", value: "application/json"))
            return headers//HTTPHeaders([HTTPHeader(name: "Content-Type", value: "application/json"), HTTPHeader(name: "language", value: YZApp.shared.language.apiParameter)])
        }
    }
}

/// It will define mime types for uploading data to server
///
/// - videoMP4: MP4 Video mime type
/// - imageJPEG: JPEG Image mime type
enum YZMediaMimeType: String {
    case videoMP4 = "video/mp4"
    case imageJPEG = "image/jpeg"
}

typealias APIBlock = (_ json: Any?, _ flag: Int) -> ()
typealias YZProgress = (Progress) -> ()?
typealias YZFileBlock = (_ path: URL?, _ success: Bool) -> ()
typealias CallBackBlock = ((Bool) -> ())
typealias UpdateDataBlock = (_ data: Any) -> ()

// MARK:- Struct YZTokenAdapter
struct YZTokenAdapter: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        if let authorizationToken = YZApp.shared.getAuthorizationToken() {
            adaptedRequest.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(adaptedRequest))
    }
}

// MARK:- Class YZAPI
class YZAPI: NSObject{
    static var call: YZAPI = YZAPI()
    let session = Alamofire.Session.default
    var networkManager = NetworkReachabilityManager.default!
    var toast: YZValidationToastView!
    var paramEncode: ParameterEncoding = URLEncoding.default
    var successBlock: (String, HTTPURLResponse?, Any?, @escaping APIBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, @escaping APIBlock) -> Void
    
    override init() {
        // Will be called on success of web service calls.
        successBlock = { (relativePath, res, respObj, block) -> Void in
            // Check for response it should be there as it had come in success block
            if let response = res {
                yzPrint(items: "Response Code: \(response.statusCode)")
                yzPrint(items: "Response(\(relativePath)): \(String(describing: respObj))")
                
                if let jsonObject = respObj as? NSDictionary,let dataDict = jsonObject["data"] as? NSDictionary, let token = jsonObject.value(forKeyPath: "data.token")  as? String {
                    YZApp.shared.storeAuthorizationToken(token)//Stored user defaults
                }
                
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        block(respObj, response.statusCode)
                    }
                } else {
//                    if response.statusCode == 401 {
//                        //Prepare for navigate to root
//                        if  let dict = respObj as? [AnyHashable : Any],
//                            let dictMetaData = dict["meta"] as? Dictionary<String, Any> {
//                            if let error = dictMetaData["error"] as? String {
//                                YZValidationToast.shared.showToastOnStatusBar(error)
////                                _appDelegate.prepareForNavigateToRoot(true)
//                            }else if let message = dictMetaData["message"] as? String {
//                                YZValidationToast.shared.showToastOnStatusBar(message)
////                                _appDelegate.prepareForNavigateToRoot(true)
//                            }else{
//                                DispatchQueue.main.async {block(respObj, response.statusCode)}
//                            }
//                        }
//                    }else {
                        DispatchQueue.main.async {
                            block(respObj, response.statusCode)
                        }
//                    }
                }
            } else {
                // There might me no case this can get execute
                DispatchQueue.main.async {
                    block(nil, 404)
                }
            }
        }
        
        // Will be called on Error during web service call
        errorBlock = { (relativePath, res, error, block) -> Void in
            // First check for the response if found check code and make decision
            if let response = res {
                yzPrint(items: "Response Code: \(response.statusCode)")
                yzPrint(items: "Error Code: \(error.code)")
                
                if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData {
                    let errorDict = (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                    if errorDict != nil {
                        yzPrint(items: "Error(\(relativePath)): \(errorDict!)")
                        DispatchQueue.main.async {
                            block(errorDict!, response.statusCode)
                        }
                    } else {
                        let code = response.statusCode
                        DispatchQueue.main.async {
                            block(nil, code)
                        }
                    }
                }else if error.code == 13 {
                    DispatchQueue.main.async {block([_appName: YZApp.shared.getLocalizedText("request_time_out")] as AnyObject, error.code)}
                }else {
                    DispatchQueue.main.async {
                        block(nil, response.statusCode)
                    }
                }
                // If response not found rely on error code to find the issue
            }else if error.code == -1001  {
                yzPrint(items: "Error(\(relativePath)): \(error)")
                DispatchQueue.main.async {
                    block([_appName: YZApp.shared.getLocalizedText("request_time_out")] as AnyObject, error.code)
                }
            }else if error.code == -1003  {
                yzPrint(items: "Error(\(relativePath)): \(error)")
                DispatchQueue.main.async {
                    block([_appName: YZApp.shared.getLocalizedText("host_seems_down")] as AnyObject, error.code)
                }
            }else if error.code == -1004  {
                yzPrint(items: "Error(\(relativePath)): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    block([_appName: error.localizedDescription] as AnyObject, error.code)
                }
            }else if error.code == -1005  {
                yzPrint(items: "Error(\(relativePath)): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    block([_appName: error.localizedDescription] as AnyObject, error.code)
                }
            }else if error.code == -1009  {
                yzPrint(items: "Error(\(relativePath)): \(error)")
                DispatchQueue.main.async {
                    block([_appName: YZApp.shared.getLocalizedText("no_internet_connection")] as AnyObject, error.code)
                }
            }else if error.code == 13 {
                DispatchQueue.main.async {block([_appName: YZApp.shared.getLocalizedText("request_time_out")] as AnyObject, error.code)}
            }else if AFError.explicitlyCancelled.isExplicitlyCancelledError {
                yzPrint(items: "Error(\(relativePath)): \(error.localizedDescription)")
                DispatchQueue.main.async {block(nil, error.code)}
            }else{
                yzPrint(items: "Error(\(relativePath)): \(error.localizedDescription)")
                DispatchQueue.main.async {block(nil, error.code)}
            }
        }
        
        super.init()
        //Add internet connectivity listner
        addInterNetListner()
    }
    
    deinit {
        networkManager.stopListening()
    }
}

//MARK: - API message
extension YZAPI {
    
    //It will display message from API reponse.
    func showAPIMessage(_ anyObject: Any?, messageFor: APIMessageFor) {
        let message = apiMessage(anyObject)
        
        YZValidationToast.shared.showToastOnStatusBar(message, color: messageFor == .success ? UIColor.TOASTSUCCESS! : UIColor.TOASTERROR!)
    }
    
    @discardableResult func apiMessage(_ anyObject: Any?) -> String {
        var message: String = YZApp.shared.getLocalizedText("something_went_wrong")
        if let dictJSON = anyObject as? Dictionary<String, Any> {
            if let dictMetaData = dictJSON["message"] as? Dictionary<String, Any> {
                if let apiMessage = dictMetaData["error"] as? String {
                    message = apiMessage
                } else if let apiMessage = dictMetaData["success"] as? String {
                    message = apiMessage
                }
            }else if let errorMsg = dictJSON[_appName] as? String {
                message = errorMsg
            }
            yzPrint(items: "apiMessage : " + message)
        }
        return message
    }
}

// MARK: Other methods
extension YZAPI{
    
    private func getFullAPIUrl(_ apiPath: String) throws -> URL {
        do{
            if apiPath.lowercased().contains("http") || apiPath.lowercased().contains("www") || apiPath.lowercased().contains("https") {
                return try apiPath.asURL()
            }else{
                return try (YZAPIMode.apiBasePath() + apiPath).asURL()
            }
        }catch let err{
            throw err
        }
    }
    
    func setAccesTokenToHeader(token: String){
//        session.adapter = YZTokenAdapter(accessToken: token)
    }
    
    func setLanguagePreferenceToHeader() {
    }
    
    func removeAccessTokenFromHeader(){
        //session.adapter = nil
    }
}

// MARK: - Request, ImageUpload and Dowanload methods
extension YZAPI{
    
    @discardableResult private func getRequest(_ apiPath: String, parameters: [String: Any]? = nil, headers: HTTPHeaders = HTTPHeaders.default, block: @escaping APIBlock)-> DataRequest? {
        do{
            yzPrint(items: "Request Url: \(try getFullAPIUrl(apiPath))")
            yzPrint(items: "Parameters : \(String(describing: parameters))")
            return session.request(try getFullAPIUrl(apiPath), method: HTTPMethod.get, parameters: parameters, encoding: paramEncode, headers: headers, interceptor: YZTokenAdapter()).responseJSON { (response) in
                yzPrint(items: "Request&Response timeline : \(response.serializationDuration)")
                switch response.result {
                case .success:
                    if let resData = response.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData)
                            DispatchQueue.main.async {self.successBlock(apiPath, response.response, res, block)}
                        } catch let parsingError as NSError {
                            yzPrint(items: "getRequest.do.session.request.success.catch : (\(apiPath)) parsingError " + parsingError.localizedDescription )
                            DispatchQueue.main.async {self.errorBlock(apiPath, response.response, parsingError, block)}
                        }
                    }
                    break
                case .failure(let error as NSError):
                    yzPrint(items: "getRequest.do.session.request.failure : (\(apiPath)) error " + error.localizedDescription )
                    if error.code == -1005 {
                        self.getRequest(apiPath, parameters: parameters, headers: headers, block: block)
                    }else{
                        DispatchQueue.main.async {self.errorBlock(apiPath, response.response, error, block)}
                    }
                    break
                }
            }
        }catch let error as NSError {
            yzPrint(items: "getRequest.catch: (\(apiPath)) error " + error.localizedDescription )
            DispatchQueue.main.async {self.errorBlock(apiPath, nil, error, block)}
            return nil
        }
    }
    
    @discardableResult private func postRequest(_ apiPath: String, parameters: [String: Any]?, headers: HTTPHeaders = HTTPHeaders.default, encoding: ParameterEncoding = JSONEncoding.default, block: @escaping APIBlock)-> DataRequest? {
        do{
            yzPrint(items: "Request Url: \(try getFullAPIUrl(apiPath))")
            yzPrint(items: "Parameters : \(String(describing: parameters))")
            return session.request(try getFullAPIUrl(apiPath), method: HTTPMethod.post, parameters: parameters, encoding: paramEncode, headers: headers, interceptor: YZTokenAdapter()).responseJSON { (response) in
                yzPrint(items: "Request&Response timeline : \(response.serializationDuration)")
                switch response.result{
                case .success:
                    if let resData = response.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData)
                            DispatchQueue.main.async {self.successBlock(apiPath, response.response, res, block)}
                        } catch let parsingError as NSError {
                            yzPrint(items: "postRequest.do.session.request.success.catch : (\(apiPath)) parsingError " + parsingError.localizedDescription )
                            DispatchQueue.main.async {self.errorBlock(apiPath, response.response, parsingError, block)}
                        }
                    }
                    break
                case .failure(let error as NSError):
                    yzPrint(items: "postRequest.do.session.request.failure : (\(apiPath)) error " + error.localizedDescription )
                    if error.code == -1005 {
                        self.postRequest(apiPath, parameters: parameters, headers: headers, encoding: encoding, block: block)
                    }else{
                        DispatchQueue.main.async {self.errorBlock(apiPath, response.response, error as NSError, block)}
                    }
                    break
                }
            }
        }catch let error {
            yzPrint(items: "postRequest.catch: (\(apiPath)) error " + error.localizedDescription )
            DispatchQueue.main.async {self.errorBlock(apiPath, nil, error as NSError, block)}
            return nil
        }
    }
    
    @discardableResult private func patchRequest(_ apiPath: String, parameters: [String: Any]?, headers: HTTPHeaders = HTTPHeaders.default, encoding: ParameterEncoding = JSONEncoding.default, block: @escaping APIBlock)-> DataRequest? {
        do{
            yzPrint(items: "Request Url: \(try getFullAPIUrl(apiPath))")
            yzPrint(items: "Parameters : \(String(describing: parameters))")
            return session.request(try getFullAPIUrl(apiPath), method: HTTPMethod.post, parameters: parameters, encoding: paramEncode, headers: headers, interceptor: YZTokenAdapter()).responseJSON { (response) in
                yzPrint(items: "Request&Response timeline : \(response.serializationDuration)")
                switch response.result{
                case .success:
                    if let resData = response.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData)
                            DispatchQueue.main.async {self.successBlock(apiPath, response.response, res, block)}
                        } catch let parsingError as NSError {
                            yzPrint(items: "postRequest.do.session.request.success.catch : (\(apiPath)) parsingError " + parsingError.localizedDescription )
                            DispatchQueue.main.async {self.errorBlock(apiPath, response.response, parsingError, block)}
                        }
                    }
                    break
                case .failure(let error as NSError):
                    yzPrint(items: "postRequest.do.session.request.failure : (\(apiPath)) error " + error.localizedDescription )
                    if error.code == -1005 {
                        self.postRequest(apiPath, parameters: parameters, headers: headers, encoding: encoding, block: block)
                    }else{
                        DispatchQueue.main.async {self.errorBlock(apiPath, response.response, error as NSError, block)}
                    }
                    break
                }
            }
        }catch let error {
            yzPrint(items: "postRequest.catch: (\(apiPath)) error " + error.localizedDescription )
            DispatchQueue.main.async {self.errorBlock(apiPath, nil, error as NSError, block)}
            return nil
        }
    }
    
    private func postRequestInFormData(_ apiPath: String, parameters: [String : Any], headers: HTTPHeaders = HTTPHeaders.default, block: @escaping APIBlock, progress: YZProgress?) {
        do {
            yzPrint(items: "Request Url: \(try getFullAPIUrl(apiPath))")
            yzPrint(items: "Parameters : \(String(describing: parameters))")
            _ = session.upload(multipartFormData: { (multiPartFormData) in
                //More parameters with details
                for (key, value) in parameters {
                    if let dataOfValue = self.convertToMultipartForm(value)?.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                        multiPartFormData.append(dataOfValue, withName: key)
                    }
                }
            }, to: try getFullAPIUrl(apiPath), method: HTTPMethod.post, headers: headers, interceptor: YZTokenAdapter()).uploadProgress { (uploadProgress) in
                progress?(uploadProgress)
            }.responseJSON { (response) in
                yzPrint(items: "Request&Response timeline : \(response.serializationDuration)")
                switch response.result {
                case .success:
                    if let resData = response.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData)
                            DispatchQueue.main.async {self.successBlock(apiPath, response.response, res, block)}
                        } catch let parsingError as NSError {
                            yzPrint(items: "postRequestInFormData.do.session.upload.failure : (\(apiPath)) parsingError " + parsingError.localizedDescription )
                            DispatchQueue.main.async {self.errorBlock(apiPath, response.response, parsingError, block)}
                        }
                    }
                    break
                case .failure(let error as NSError):
                    yzPrint(items: #function + ".do.session.request.failure : (\(apiPath)) error " + error.localizedDescription )
                    if error.code == -1005 {
                        self.postRequestInFormData(apiPath, parameters: parameters, headers: headers, block: block, progress: progress)
                    }else{
                        DispatchQueue.main.async {self.errorBlock(apiPath, nil, error, block)}
                    }
                    break
                }
            }
        } catch let error as NSError {
            yzPrint(items: "postRequestInFormData.catch: (\(apiPath)) error " + error.localizedDescription )
            DispatchQueue.main.async {self.errorBlock(apiPath, nil, error, block)}
        }
    }
    
    @discardableResult private  func deleteRequest(_ apiPath: String, parameters: [String: Any]? = nil, headers: HTTPHeaders  = HTTPHeaders.default, block: @escaping APIBlock)-> DataRequest? {
        do{
            yzPrint(items: "Request Url: \(try getFullAPIUrl(apiPath))")
            yzPrint(items: "Parameters : \(String(describing: parameters))")
            return session.request(try getFullAPIUrl(apiPath), method: HTTPMethod.delete, parameters: parameters, encoding: paramEncode, headers: headers, interceptor: YZTokenAdapter()).responseJSON { (response) in
                yzPrint(items: "Request&Response timeline : \(response.serializationDuration)")
                switch response.result {
                case .success:
                    if let resData = response.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData)
                            DispatchQueue.main.async {
                                self.successBlock(apiPath, response.response, res, block)
                            }
                        } catch let parsingError as NSError {
                            yzPrint(items: #function + ".do.session.parsingError : (\(apiPath)) error " + parsingError.localizedDescription )
                            DispatchQueue.main.async {
                                self.errorBlock(apiPath, response.response, parsingError, block)
                            }
                        }
                    }
                    break
                case .failure(let error as NSError):
                    yzPrint(items: #function + ".do.session.request.failure : (\(apiPath)) error " + error.localizedDescription )
                    if error.code == -1005 {
                        self.deleteRequest(apiPath, parameters: parameters, headers: headers, block: block)
                    }else{
                        DispatchQueue.main.async {self.errorBlock(apiPath, response.response, error, block)}
                    }
                    break
                }
            }
        }catch let error as NSError {
            yzPrint(items: "deleteRequest.catch: (\(apiPath)) error " + error.localizedDescription )
            DispatchQueue.main.async {self.errorBlock(apiPath, nil, error, block)}
            return nil
        }
    }
    
    
    @discardableResult private func uploadFiles(_ apiPath: String, fileParameters: [String], filesData: [Data?], parameters: [String: Any]? = nil, headers: HTTPHeaders = HTTPHeaders.default, method: HTTPMethod = .post, block: @escaping APIBlock, progress: YZProgress? = nil) -> UploadRequest? {
        do{
            yzPrint(items: "Request Url: \(try getFullAPIUrl(apiPath))")
            yzPrint(items: "Parameters : \(String(describing: parameters))")
            return session.upload(multipartFormData: { (formData) in
                if filesData.isEmpty == false {
                    for (index, fileData) in filesData.enumerated() {
                        if let fileData = fileData {
                            formData.append(fileData, withName: fileParameters[index], fileName: "image.jpeg", mimeType: YZMediaMimeType.imageJPEG.rawValue)
                        }
                    }
                }
                
                if let parameters = parameters {
                    for (key, value) in parameters {
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullAPIUrl(apiPath), method: HTTPMethod.post, headers: headers, interceptor: YZTokenAdapter()).uploadProgress { (uploadProgress) in
                progress?(uploadProgress)
            }.responseJSON { (response) in
                yzPrint(items: "Request&Response timeline : \(response.serializationDuration)")
                switch response.result {
                case .success:
                    if let resData = response.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData)
                            DispatchQueue.main.async {
                                self.successBlock(apiPath, response.response, res, block)
                            }
                        } catch let parsingError as NSError {
                            yzPrint(items: "postRequestInFormData.do.session.upload.failure : (\(apiPath)) parsingError " + parsingError.localizedDescription )
                            DispatchQueue.main.async {self.errorBlock(apiPath, response.response, parsingError, block)}
                        }
                    }
                    break
                case .failure(let error as NSError):
                    yzPrint(items: #function + ".do.session.request.failure : (\(apiPath)) error " + error.localizedDescription )
                    if error.code == -1005 {
                        self.uploadFiles(apiPath, fileParameters: fileParameters, filesData: filesData, parameters: parameters, headers: headers, block: block, progress: progress)
                    }else{
                        DispatchQueue.main.async {self.errorBlock(apiPath, nil, error, block)}
                    }
                    break
                }
            }
        }catch let error as NSError {
            yzPrint(items: "uploadFiles.catch: (\(apiPath)) error " + error.localizedDescription )
            DispatchQueue.main.async {self.errorBlock(apiPath, nil, error, block)}
            return nil
        }
    }
    
    @discardableResult private func uploadFileAWS(_ apiPath: String, fileParameters: [String], filesData: Data, parameters: [String: Any]? = nil, headers: HTTPHeaders = HTTPHeaders.default, method: HTTPMethod = .put, block: @escaping APIBlock, progress: YZProgress? = nil) -> UploadRequest? {
        do {
            yzPrint(items: "Request Url: \(try getFullAPIUrl(apiPath))")
            yzPrint(items: "Parameters : \(String(describing: parameters))")
            return session.upload(filesData, to:try getFullAPIUrl(apiPath), method: HTTPMethod.put, headers: nil, interceptor: nil).response { (response) in
                yzPrint(items: response.data)
                block(nil, response.response?.statusCode ?? 200)
            }
        } catch let error as NSError {
                yzPrint(items: "uploadFiles.catch: (\(apiPath)) error " + error.localizedDescription )
                DispatchQueue.main.async {self.errorBlock(apiPath, nil, error, block)}
                return nil
            }
        }
    
    
    private func dowanloadFile(_ apiPath: String, saveFileWithName: String, progress: YZProgress?, block: @escaping YZFileBlock) -> DownloadRequest? {
        // Create destination URL
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent(saveFileWithName)
        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
            DispatchQueue.main.async {
                block(destinationFileUrl, true)
            }
            return nil
        }else{
            let destination: DownloadRequest.Destination = { _, _ in
                return (destinationFileUrl, [.removePreviousFile, .createIntermediateDirectories])
            }
            do{
                return session.download(try apiPath.asURL(), to: destination).downloadProgress { (downloadProgress) in
                    DispatchQueue.main.async {
                        progress?(downloadProgress)
                    }
                }.response{ (response) in
                    if let finalPath = response.fileURL, response.error == nil {
                        DispatchQueue.main.async {
                            block(finalPath, true)
                        }
                    }else{
                        yzPrint(items: String(describing: response.error?.localizedDescription))
                        DispatchQueue.main.async {
                            block(nil, false)
                        }
                    }
                }.resume()
            }catch{
                DispatchQueue.main.async {
                    block(nil, false)
                }
                return nil
            }
        }
    }
}

//MARK: - Internet Availability
extension YZAPI{
    
    func addInterNetListner() {
        networkManager.startListening {[weak self](status) in
            guard let weakSelf = self else{return}
            if case .reachable(_) = status {
                yzPrint(items: "Internet available")
                _appDelegate.isStatusBarHidden = false
                _defaultCenter.post(name: nfInternetAvailable, object: nil)
                if weakSelf.toast != nil {
                    weakSelf.toast.animateOut(duration: 0.2, delay: 0.2, completion: { () -> () in
                        weakSelf.toast.removeFromSuperview()
                        _appDelegate.isStatusBarHidden = false
                        _defaultCenter.post(name: nfInternetAvailable, object: nil)
                    })
                }
            }else{
                yzPrint(items: "No internet available")
                _appDelegate.isStatusBarHidden = false
                _defaultCenter.post(name: nfInternetNotAvailable, object: nil)
//                weakSelf.toast = YZValidationToast.shared.showToastOnStatusBar(YZApp.shared.getLocalizedText("no_internet_connection"), autoHide: false)
            }
        }
    }
    func isInternetAvailable() -> Bool {
        if networkManager.isReachable {
            return true
        }else{
            return false
        }
    }

}

//MARK: - Adaptive method
extension YZAPI {
    
    func convertToMultipartForm(_ anyObject: Any) -> String? {
        if let string = anyObject as? String {
            return string
        }else if let simBool = anyObject as? Bool {
            return simBool.description
        }else if let simNum = anyObject as? NSNumber {
            return simNum.stringValue
        }else {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: anyObject, options: [])
                if let stringOfJSONData = String(data: jsonData, encoding: .utf8) {
                    let removeSlah = stringOfJSONData.replacingOccurrences(of: "\\", with: "")
                    //yzPrint(items: "removeSlah : \(removeSlah)")
                    return removeSlah
                }else{
                    return nil
                }
            }catch _ {
                if let string = anyObject as? String {
                    return string
                }else if let simBool = anyObject as? Bool {
                    return simBool.description
                }else if let simNum = anyObject as? NSNumber {
                    return simNum.stringValue
                }else {
                    return nil
                }
            }
        }
    }
}

//MARK: - YZAPI(s)
struct YZAPIs {
//    case apiVersion           = "v3/"
    static let socialLogin           = "Social"
    static let signIn           = "signin"
    static let signup           =  "signup"
    static let getMiningDetails = "get_mingin_balance"
    static let getNews = "getNews"
    static let getTeams = "getTeams"
    static let startMining = "startMining"
    static let updateProfile = "updateProfile"
    static let getMiningTransactionHistory = "getMiningTransactionHistory"
    static let getUsersNotification = "getUsersNotification"
    static let getRanking = "getRanking"
    static let getCountryList = "getCountryList"
    static let getTeamsEarning = "getTeamsEarning"
    static let sendNotification = "sendNotification"
    static let sendNotificationInActiveUsers = "sendNotificationInActiveUsers"
    static let getMetaData = "getMetaData"
    static let logout = "logout"
    
//    func addVersionToURL() -> String {
//        return YZAPIs.apiVersion.rawValue + self.rawValue
//    }

}

extension YZAPI {
    func productList(block: @escaping APIBlock) {
//        getRequest(YZAPIs.products.addVersionToURL(), parameters: nil, block: block)
    }
    
    func categories(block: @escaping APIBlock) {
//        getRequest(YZAPIs.categories.addVersionToURL(), parameters: nil, block: block)
    }
}
//MARK: Google APIs
extension YZAPI {
    
    func getAddressFromLoc(url: String, _ block: @escaping APIBlock) -> DataRequest? {
        if let escapedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return postRequest(escapedString, parameters: nil, block: block)
        }
        return nil
    }
    
    func serachPlaces(url: String, _ block: @escaping APIBlock) -> DataRequest? {
        if let escapedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return postRequest(escapedString, parameters: nil, block: block)
        }
        return nil
    }
}


//MARK: Local DB APIs
extension YZAPI {
    
    func authorizedUsing(_ socialUser: SocialUser, block: @escaping APIBlock) {
        if socialUser.type == .facebook {
            yzPrint(items: "====================== FACEBOOK SIGN IN ======================")
            postRequest(YZAPIs.socialLogin, parameters: socialUser.requestParameterForFacebook, block: block)
        } else if socialUser.type == .google {
            yzPrint(items: "====================== GOOGLE SIGN IN ======================")
            postRequest(YZAPIs.socialLogin, parameters: socialUser.requestParameterForGoogle, block: block)
        } else {
            yzPrint(items: "====================== APPLE SIGN IN ======================")
            postRequest(YZAPIs.socialLogin, parameters: socialUser.requestParameterForApple, block: block)
        }
    }
    
    func signIn(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.signIn, parameters: paramDict, block: block)
    }
    
    func signUp(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.signup, parameters: paramDict, block: block)
    }
    
    func getMiningDetail(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest("http://hbcucrypto.com:3003/"+YZAPIs.getMiningDetails, parameters: paramDict, block: block)
    }
    
    func getNews(_ paramDict: [String:Any]?, block: @escaping APIBlock) {
        postRequest("http://hbcucrypto.com:3003/"+YZAPIs.getNews, parameters: paramDict, block: block)
    }
    
    func getTeams(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest("http://hbcucrypto.com:3003/"+YZAPIs.getTeams, parameters: paramDict, block: block)
    }
    
    func startMining(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest("http://hbcucrypto.com:3003/"+YZAPIs.startMining, parameters: paramDict, block: block)
    }
    
    func updateProfile(_ data: Data?,_ paramDict: [String:Any], block: @escaping APIBlock) {
        uploadFiles(YZAPIs.updateProfile, fileParameters: ["avtar"], filesData: [data], parameters: paramDict,  block: block)
    }
    
    func getMiningHistory(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest("http://hbcucrypto.com:3003/"+YZAPIs.getMiningTransactionHistory, parameters: paramDict, block: block)
    }
    
    func getNotificationsList(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.getUsersNotification, parameters: paramDict, block: block)
    }
    
    func getRankingList(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.getRanking, parameters: paramDict, block: block)
    }
    
    func getCountryList(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.getCountryList, parameters: paramDict, block: block)
    }
    
    func getTeamEarnings(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.getTeamsEarning, parameters: paramDict, block: block)
    }
    
    func sendNotificationOnPing(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.sendNotification, parameters: paramDict, block: block)
    }
    
    func sendNotificationToInactiveUser(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.sendNotificationInActiveUsers, parameters: paramDict, block: block)
    }
    
    func getMetaData(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.getMetaData, parameters: paramDict, block: block)
    }
    
    func logout(_ paramDict: [String:Any], block: @escaping APIBlock) {
        postRequest(YZAPIs.logout, parameters: paramDict, block: block)
    }
}
