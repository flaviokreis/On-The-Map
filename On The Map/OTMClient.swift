//
//  OTMClient.swift
//  On The Map
//
//  Created by Flavio Kreis on 13/02/17.
//  Copyright © 2017 Flavio Kreis. All rights reserved.
//

import UIKit

class OTMClient: NSObject {
    
    // shared session
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    func getUsersLocation(isReload: Bool, completionHandler: @escaping (_ students: [StudentLocation], _ errorString: String?) -> Void) {
        
        let dataSource = OTMDataSource.sharedInstance()
        
        if !isReload && (dataSource.studentLocations.count > 0) {
            completionHandler(dataSource.studentLocations, nil)
            return
        }
        
        let parameters: [String:AnyObject] = [
            RequestParams.limit : 100 as AnyObject
        ]
        
        let url = urlFromParameters(host: Parser.Host, parameters: parameters, withPath: Parser.StudentLocationPath)
        
        print(url.absoluteString)
        
        let _ = taskForParserGETMethod(url) { (results, error) in
            guard error == nil else {
                completionHandler([], "Error on try get students.")
                return
            }
            
            guard let results = results else {
                completionHandler([], "Error on try get students.")
                return
            }
            
            if let students = results[JSONResponseKeys.results] as? [[String:AnyObject]] {
                //Remove all old students to prevent duplicate list
                dataSource.studentLocations.removeAll()
                
                for value in students {
                    print(value)
                    let student = StudentLocation(dictionary: value)
                    dataSource.studentLocations.append(student)
                }
                
                completionHandler(dataSource.studentLocations, nil)
                
                self.verifyIfLocationWasAdded()
            }
        }
    }
    
    func verifyIfLocationWasAdded(){
        let dataSource = OTMDataSource.sharedInstance()
        
        let parameters: [String:AnyObject] = [
            RequestParams.where_ : "{\"\(RequestParams.uniqueKey)\":\"\(dataSource.user!.uniqueKey)\"}" as AnyObject
        ]
        
        let url = urlFromParameters(host: Parser.Host, parameters: parameters, withPath: Parser.StudentLocationPath)
        
        print(url.absoluteString)
        
        let _ = taskForParserGETMethod(url) { (results, error) in
            guard error == nil else {
                return
            }
            
            guard let results = results else {
                return
            }
            
            if let students = results[JSONResponseKeys.results] as? [[String:AnyObject]], students.count > 0 {
                let first = students[0]
                if let objectId = first[JSONResponseKeys.objectID] as? String {
                   dataSource.locationObjectId = objectId
                }
            }
        }
    }
    
    func addStudentLocation(_ studentLocation: StudentLocation, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void){
        if studentLocation.objectID != "" {
            updateLocation(studentLocation, completionHandler: completionHandler)
        }
        else {
            postLocation(studentLocation, completionHandler: completionHandler)
        }
    }
    
    private func postLocation(_ studentLocation: StudentLocation, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void){
       
        let dataSource = OTMDataSource.sharedInstance()
        
        let url = urlFrom(host: Parser.Host, withPath: Parser.StudentLocationPath)
        
        let json = "{\"\(RequestParams.uniqueKey)\": \"\(studentLocation.student.uniqueKey)\", \"\(RequestParams.firstName)\": \"\(studentLocation.student.firstName)\", \"\(RequestParams.lastName)\": \"\(studentLocation.student.lastName)\",\"\(RequestParams.mapString)\": \"\(studentLocation.location.mapString)\", \"\(RequestParams.mediaURL)\": \"\(studentLocation.student.mediaURL)\",\"\(RequestParams.latitude)\": \(studentLocation.location.latitude), \"\(RequestParams.longitude)\": \(studentLocation.location.longitude)}"
        
        let _ = taskForParserPOSTMethod(url, jsonBody: json) { (results, error) in
            guard error == nil else {
                completionHandler(false, "Error on try add user location.")
                return
            }
            
            guard let results = results else {
                completionHandler(false, "Error on try add user location.")
                return
            }
            
            if let objectId = results[JSONResponseKeys.objectID] as? String {
                dataSource.locationObjectId = objectId
                completionHandler(true, nil)
            }
        }
    }
    
    private func updateLocation(_ studentLocation: StudentLocation, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void){
        
        let dataSource = OTMDataSource.sharedInstance()
        
        let url = urlFrom(host: Parser.Host, withPath: Parser.StudentLocationPath + "\(dataSource.locationObjectId)")
        
        let json = "{\"\(RequestParams.uniqueKey)\": \"\(studentLocation.student.uniqueKey)\", \"\(RequestParams.firstName)\": \"\(studentLocation.student.firstName)\", \"\(RequestParams.lastName)\": \"\(studentLocation.student.lastName)\",\"\(RequestParams.mapString)\": \"\(studentLocation.location.mapString)\", \"\(RequestParams.mediaURL)\": \"\(studentLocation.student.mediaURL)\",\"\(RequestParams.latitude)\": \(studentLocation.location.latitude), \"\(RequestParams.longitude)\": \(studentLocation.location.longitude)}"
        
        let _ = taskForParserPUTMethod(url, jsonBody: json) { (results, error) in
            guard error == nil else {
                completionHandler(false, "Error on try add user location.")
                return
            }
            
            guard let results = results else {
                completionHandler(false, "Error on try add user location.")
                return
            }
            
            if let updatedAt = results[JSONResponseKeys.updatedAt] as? String {
                print("Updated at: \(updatedAt)")
                completionHandler(true, nil)
            }
        }
    }
    
    func login(email: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void){
        
        loginUdacity(email: email, password: password) { (userKey, error) in
            guard error == nil else {
                completionHandlerForAuth(false, error)
                return
            }
            
            guard let userKey = userKey else {
                completionHandlerForAuth(false, "Email or password is wrong.")
                return
            }
            
            self.getUserInfo(userKey: userKey, completionHandlerForUserInfo: { (success, error) in
                completionHandlerForAuth(success, error)
            })
        }
        
    }
    
    private func loginUdacity(email: String, password: String, completionHandlerForLogin: @escaping (_ userKey: String?, _ errorString: String?) -> Void){
        
        let url = urlFrom(host: OTMClient.Udacity.Host, withPath: OTMClient.Udacity.SessionPath)
        let jsonBody = "{\"\(RequestParams.udacity)\": {\"\(RequestParams.username)\": \"\(email)\", \"\(RequestParams.password)\": \"\(password)\"}}"
        
        let _ = taskForUdacityPOSTMethod(url, jsonBody: jsonBody) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForLogin(nil, "Email or password is wrong.")
            }
            else{
                if let account = results?[JSONResponseKeys.account] as? [String:Any], let userKey = account[JSONResponseKeys.key] as? String {
                    completionHandlerForLogin(userKey, nil)
                }
                else{
                    completionHandlerForLogin(nil, "Email or password is wrong.")
                }
            }
        }
    }
    
    private func getUserInfo(userKey: String, completionHandlerForUserInfo: @escaping (_ success: Bool, _ errorString: String?) -> Void){
        
        let url = urlFrom(host: OTMClient.Udacity.Host, withPath: OTMClient.Udacity.UserPath + userKey)
        
        let _ = taskForUdacityGETMethod(url) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForUserInfo(false, "Error on try get user information.")
            }
            else{
                if let userInfo = results?[JSONResponseKeys.user] as? [String:Any], let firstName = userInfo[JSONResponseKeys.first_name] as? String, let lastName = userInfo[JSONResponseKeys.last_name] as? String {
                    let user = Student(uniqueKey: userKey, firstName: firstName, lastName: lastName, mediaURL: "")
                    OTMDataSource.sharedInstance().user = user;
                    
                    completionHandlerForUserInfo(true, nil)
                }
                else{
                    completionHandlerForUserInfo(false, "Error on try get user information.")
                }
            }
        }
    }
    
    func taskForMethod(_ request: NSMutableURLRequest, isUdacity: Bool, completionRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionRequest(nil, NSError(domain: "taskForMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            print("status code: \((response as? HTTPURLResponse)?.statusCode)")
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if isUdacity {
                let range = Range(uncheckedBounds: (5, data.count))
                let newData = data.subdata(in: range)
                
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionRequest)
            }
            else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionRequest)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: GET
    
    func taskForParserGETMethod(_ url: URL, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: url)
        request.addValue(Parser.ApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parser.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        return taskForMethod(request, isUdacity: false, completionRequest: completionHandlerForGET)
    }
    
    func taskForParserPOSTMethod(_ url: URL, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(Parser.ApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parser.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        return taskForMethod(request, isUdacity: false, completionRequest: completionHandlerForPOST)
    }
    
    func taskForParserPUTMethod(_ url: URL, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(Parser.ApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parser.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        return taskForMethod(request, isUdacity: false, completionRequest: completionHandlerForPOST)
    }
    
    func taskForUdacityGETMethod(_ url: URL, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        return taskForMethod(request, isUdacity: true, completionRequest: completionHandlerForGET)
    }
    
    // MARK: POST
    
    func taskForUdacityPOSTMethod(_ url: URL, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        return taskForMethod(request, isUdacity: true, completionRequest: completionHandlerForPOST)
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // create a URL from parameters
    private func urlFromParameters(host: String, parameters: [String:AnyObject], withPath: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = host
        
        components.path = withPath ?? ""
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // create a URL
    private func urlFrom(host: String, withPath: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = host
        components.path = withPath ?? ""
        components.queryItems = [URLQueryItem]()
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }

}
