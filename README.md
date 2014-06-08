YYHRequest
==========

`YYHRequest` is a simple and lightweight class for loading asynchronous HTTP requests in Swift. Built on `NSURLConnection` and `NSOperationQueue`. `YYHRequest` is not intended to be a full-featured networking framework but instead a simple wrapper to avoid the boilerplate of using `NSURLConnection` and `NSURLRequest` for simple networking tasks.

- Lightweight design - just a single wrapper class
- Avoid the boilerplate of `NSURLConnection` and `NSURLRequest` for simple networking tasks
- Simple API for setting request headers, query parameters, and form data

Original Objective-C version [available here](https://github.com/yayuhh/YYHRequest).

## Getting Started

Create and load a request

    var url: NSURL = NSURL(string: "http://www.google.com/")
    var request: YYHRequest = YYHRequest(url: url)

    request.loadWithCompletion {response, data, error in
        if let actualError = error {
            // handle error
        } else if let actualResponse = response {
            // handle success
        }
    }

Create request and load manually.


    var request: YYHRequest = YYHRequest(url: url)
    request.method = "POST"
    request.parameters["foo"] = "bar"

    request.completionHandler = { response, data, error in
        // request complete!
    }

    request.loadRequest()

## Usage

### Load a Request

    var url: NSURL = NSURL(string: "http://www.google.com/")
    var request: YYHRequest = YYHRequest(url: url)

    request.loadWithCompletion { response, data, error in
        // request complete!
    }

HTTP

    GET /

### Customize a Request

    // set request method
    request.method = "PUT";

    // set HTTP headers using headers dictionary
    request.headers["User-Agent"] = "value";

    // set header values via properties
    request.userAgent = "value";

HTTP

    PUT /
    User-Agent: value
    Content-Type: application/x-www-form-urlencoded

### Sending Query Parameters

    var request: YYHRequest = YYHRequest(url: url)
    request.parameters["foo"] = "bar"

HTTP

    GET /?foo=bar

### Posting Data

    var request: YYHRequest = YYHRequest(url: url)
    request.method = "POST"
    request.parameters["foo"] = "bar"

HTTP

    POST /
    Content-Type: application/x-www-form-urlencoded
    foo=bar
