//
//  YYHRequestTests.swift
//  YYHRequestTests
//
//  Created by Angelo Di Paolo on 6/3/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

import XCTest
import YYHRequest

class YYHRequestTests: XCTestCase {
    
    class func placeholderRequest() -> YYHRequest {
        let url: NSURL = NSURL(string: "http://www.google.com/")
        let request: YYHRequest = YYHRequest(url: url)
        request.parameters["name"] = "Mordecai"
        request.parameters["occupation"] = "Groundskeeper"
        request.parameters["supervisor"] = "Benson"
        request.contentType = "test/plain"
        request.userAgent = "my user agent"
        return request
    }
    
    func testDefaultProperties() {
        let request: YYHRequest = YYHRequestTests.placeholderRequest()
        XCTAssertEqual(request.method, "GET", "request.method should be equal to GET")
    }
    
    func testSetHeaderProperties() {
        let request: YYHRequest = YYHRequestTests.placeholderRequest()
        XCTAssert(request.contentType == request.headers["Content-Type"])
        XCTAssert(request.userAgent == request.headers["User-Agent"])
    }
    
    func testUrlRequest() {
        let url: NSURL = NSURL(string: "http://www.google.com/")
        let request: YYHRequest = YYHRequest(url: url)
        
        let urlRequest = request.urlRequest()
        XCTAssertEqual(urlRequest.URL, request.url)
        XCTAssertTrue(urlRequest.HTTPBody.isEqualToData(request.body))	        
        XCTAssertEqual(urlRequest.HTTPMethod, request.method)
        
        for (field, value) in request.headers {
            XCTAssertEqual(value, urlRequest.valueForHTTPHeaderField(field), "header value should be equal")
        }
    }
    
    func testQueryString() {
        let request: YYHRequest = YYHRequestTests.placeholderRequest()
        var queryString = request.queryString()
        XCTAssert(queryString.hasPrefix("?"), "should start with ? character")
        
        queryString = queryString.stringByReplacingOccurrencesOfString("?", withString: "")
        let components = queryString.componentsSeparatedByString("&")
        
        for part in components {
            let pair = part.componentsSeparatedByString("=")
            let key = pair[0]
            let value = pair[1]
            XCTAssert(request.parameters[key] == value)
        }
    }
    
}
