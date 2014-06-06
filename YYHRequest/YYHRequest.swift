//
//  YYHRequest
//  YYHRequest
//
//  Created by Angelo Di Paolo on 6/3/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

import Foundation

let operationQueue = NSOperationQueue()

class YYHRequest: NSObject, NSURLConnectionDataDelegate {
    var url: NSURL
    var method = "GET"
    var body = NSData()
    var headers: Dictionary<String, String> = Dictionary()
    var parameters: Dictionary<String, String> = Dictionary()
    var connection: NSURLConnection?
    var response: NSURLResponse?
    var responseData = NSMutableData()
    var completionHandler: (NSURLResponse!, NSData!, NSError!) -> Void

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
        completionHandler = {
            (response: NSURLResponse!, data: NSData!, error: NSError!) in
        }
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.name = "com.yayuhh.YYHRequest"
    }
    
    // Request Loading
    
    func loadWithCompletion(completionHandler: (NSURLResponse!, NSData!, NSError!) -> Void) {
        self.completionHandler = completionHandler
        loadRequest()
    }
    
    func loadRequest() {
        if (parameters.count > 0) {
            serializeRequestParameters()
        }

        connection = NSURLConnection(request: request(), delegate: self)
        connection!.setDelegateQueue(operationQueue)
        connection!.start()
    }
    
    // Request Creation
    
    func request() -> NSMutableURLRequest {
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: self.url)
        request.HTTPMethod = self.method
        request.HTTPBody = self.body
        
        for (field, value) in self.headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        if (self.body.length > 0) {
            request.setValue(String(self.body.length), forHTTPHeaderField: "Content-Length")
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
            var encodedKey: NSString = key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            var encodedValue: NSString = value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
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
//        let data: NSData = responseData
        completionHandler(response, responseData, nil)
    }
}
