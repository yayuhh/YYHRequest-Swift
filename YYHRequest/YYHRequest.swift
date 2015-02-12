//
//  YYHRequest
//  YYHRequest
//
//  Created by Angelo Di Paolo on 6/3/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

import Foundation

public typealias YYHRequestCompletionHandler = (NSURLResponse?, NSData?, NSError?) -> Void
internal var _requestOperationQueue: NSOperationQueue?

public class YYHRequest: NSObject, NSURLConnectionDataDelegate {
    
    //MARK: Request Properties
    
    public var url: NSURL
    public var method = "GET"
    public var body: NSData?
    public var headers: Dictionary<String, String> = Dictionary()
    public var parameters: Dictionary<String, String> = Dictionary()
    public var completionHandler: YYHRequestCompletionHandler
    
    public var contentType: String? {
        set {
            headers["Content-Type"] = newValue
        }
        get {
            return headers["Content-Type"]
        }
    }
    
    public var userAgent: String? {
        set {
            headers["User-Agent"] = newValue
        }
        get {
            return headers["User-Agent"]
        }
    }

    //MARK: Response Properties

    public var response: NSURLResponse?
    public lazy var responseData = NSMutableData()
    
    //MARK: NSURLConnection
    
    internal var connection: NSURLConnection?
    
    public init(url: NSURL) {
        self.url = url
        completionHandler = {response, data, error in}
        super.init()
    }
    
    //MARK: Request Loading
    
    public func loadWithCompletion(completionHandler: YYHRequestCompletionHandler) {
        self.completionHandler = completionHandler
        loadRequest()
    }
    
    public func loadRequest() {
        if (parameters.count > 0) {
            serializeRequestParameters()
        }
        
        if _requestOperationQueue == nil {
            _requestOperationQueue = NSOperationQueue()
            _requestOperationQueue!.maxConcurrentOperationCount = 4
            _requestOperationQueue!.name = "com.yayuhh.YYHRequest"
        }
        
        connection = NSURLConnection(request: urlRequest(), delegate: self)
        connection!.setDelegateQueue(_requestOperationQueue)
        connection!.start()
    }
    
    //MARK: Request Creation
    
    public func urlRequest() -> NSMutableURLRequest {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = body
        
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        if let validBody = body {
            if (validBody.length > 0) {
                request.setValue(String(validBody.length), forHTTPHeaderField: "Content-Length")
            }
        }
        
        return request
    }
    
    //MARK: Request Parameters
    
    func serializeRequestParameters() {
        contentType = "application/x-www-form-urlencoded"
        
        if (method == "GET") {
            if let queryURL = queryParametersURL() {
                url = queryURL
            }
        } else {
            body = serializedRequestBody()
        }
    }
    
    func serializedRequestBody() -> NSData? {
        return queryString().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    }
    
    func queryParametersURL() -> NSURL? {
        return NSURL(string: url.absoluteString! + queryString())
    }
    
    public func queryString() -> String {
        var result = method == "GET" ? "?" : ""
        var firstPass = true
        
        for (key, value) in parameters {
            let encodedKey: NSString = key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let encodedValue: NSString = value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            result += firstPass ? "\(encodedKey)=\(encodedValue)" : "&\(encodedKey)=\(encodedValue)"
            firstPass = false;
        }
        
        return result
    }
    
    //MARK: NSURLConnectionDataDelegate

    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        completionHandler(nil, nil, error)
    }
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.response = response
    }
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData.appendData(data)
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        completionHandler(response, responseData, nil)
    }
}
