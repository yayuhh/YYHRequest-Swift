//
//  YYHRequest
//  YYHRequest
//
//  Created by Angelo Di Paolo on 6/3/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

import Foundation

var _requestOperationQueue: NSOperationQueue?

class YYHRequest: NSObject, NSURLConnectionDataDelegate {
    typealias YYHRequestCompletionHandler = (NSURLResponse?, NSData?, NSError?) -> Void
    
    var url: NSURL
    var method = "GET"
    var body = NSData()
    var headers: Dictionary<String, String> = Dictionary()
    var parameters: Dictionary<String, String> = Dictionary()
    var connection: NSURLConnection?
    var response: NSURLResponse?
    var responseData = NSMutableData()
    var completionHandler: YYHRequestCompletionHandler

    var contentType: String? {
    set {
        headers["Content-Type"] = newValue
    }
    get {
        return headers["Content-Type"]
    }
    }
    
    var userAgent: String? {
    set {
        headers["User-Agent"] = newValue
    }
    get {
        return headers["User-Agent"]
    }
    }
    
    init(url: NSURL) {
        self.url = url
        completionHandler = {response, data, error in}
    }
    
    // Request Loading
    
    func loadWithCompletion(completionHandler: YYHRequestCompletionHandler) {
        self.completionHandler = completionHandler
        loadRequest()
    }
    
    func loadRequest() {
        if (parameters.count > 0) {
            serializeRequestParameters()
        }
        
        if _requestOperationQueue == nil {
            _requestOperationQueue = NSOperationQueue()
            _requestOperationQueue!.maxConcurrentOperationCount = 4
            _requestOperationQueue!.name = "com.yayuhh.YYHRequest"
        }

        connection = NSURLConnection(request: request(), delegate: self)
        connection!.setDelegateQueue(_requestOperationQueue)
        connection!.start()
    }
    
    // Request Creation
    
    func request() -> NSMutableURLRequest {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.HTTPBody = body
        
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        if (body.length > 0) {
            request.setValue(String(body.length), forHTTPHeaderField: "Content-Length")
        }
        
        return request
    }
    
    // Request Parameters
    
    func serializeRequestParameters() {
        contentType = "application/x-www-form-urlencoded"
        
        if (method == "GET") {
            url = queryParametersURL()
        } else {
            body = serializedRequestBody()
        }
    }
    
    func serializedRequestBody() -> NSData {
        return queryString().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    }
    
    func queryParametersURL() -> NSURL {
        return NSURL(string: url.absoluteString + queryString())
    }
    
    func queryString() -> String {
        var result = "?"
        var firstPass = true
        
        for (key, value) in parameters {
            let encodedKey: NSString = key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let encodedValue: NSString = value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            result += firstPass ? "\(encodedKey)=\(encodedValue)" : "&\(encodedKey)=\(encodedValue)"
            firstPass = false;
        }
        
        return result
    }
    
    // NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        completionHandler(nil, nil, error)
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.response = response
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        responseData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        completionHandler(response, responseData, nil)
    }
}
