//
//  CloudManager.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/1/22.
//
/*

import SwiftUI
import SafariServices
import Alamofire
import Firebase
import Combine

final class CloudManager: ObservableObject {
    
    static var shared = CloudManager()
    //@Environment(\.firestore) var firestore
    
    /*
    static func responseData(queue: DispatchQueue = .main, dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor, emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes, emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods, completionHandler: @escaping (AFDataResponse<Data>) -> Void) {
        
    }
    
    let didChange = PassthroughSubject<CloudManager, Never>()
    let willChange = PassthroughSubject<CloudManager, Never>()
    
    @Published var completionHandlers: [(String?, String?) -> Void] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    */
    
    func createStripeConnectAccount(email: String, completion: @escaping (String?, String?) -> Void)  { //accountID, Error
        
        let params: [String: Any?] = [
            "email": email
        ]

        let url = "https://us-central1-fmfitness-bb6e6.cloudfunctions.net/striper/createConnectAccount"
        
        AF.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { [self] response in
            
            print("Response: \(response)")
            print("Response.result: \(response.result)")
            
            switch response.result {
            case .success(let data):
                print("Stripe connect data: \(data)")
                let successDict: [String: Any?] = data as! [String: Any?]
                let body = successDict["body"] as! [String: Any?]
                let acctNum = body["success"] as! String
                firestore.setProfile(parameters: ["acctNum": acctNum, "email": email])
                completion(acctNum, nil)
                
                /*
                do {
                    let successDict = try JSONSerialization.data(withJSONObject: data.self, options: [])
                    let resultObject = try! JSONDecoder().decode(OrderCreateModelClass.OrderCreateModel.self, from: successDict)
                    let body = resultObject["body"] as! [String: Any?]
                    let acctNum = body["success"] as! String
                    completion(acctNum, nil)
                } catch {
                    // Here, I like to keep a track of error if it occurs, and also print the response data if possible into String with UTF8 encoding
                    // I can't imagine the number of questions on SO where the error is because the API response simply not being a JSON and we end up asking for that "print", so be sure of it
                    print("Error while decoding response: "\(error)" from: \(String(data: data, encoding: .utf8))")
                } */
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil, error.localizedDescription)
            }
        }
    }

    func createStripeAccountLink(params: [String: Any], completion: @escaping (String?, String?) -> Void)  { //url, Error
        
        let parameters: [String: Any] = [
            "accountID": params["accountID"] as? String ?? "",
            "type": params["type"] as? String ?? "account_onboarding"
        ]
        
        let url = "https://us-central1-fmfitness-bb6e6.cloudfunctions.net/striper/createAccountLink"
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            
            switch response.result {
                case .success(let dict):
                    print("Stripe connect data: \(dict)")
                    let successDict: [String: Any?] = dict as! [String: Any?]
                    let body = successDict["body"] as! [String: Any?]
                    let link = body["success"] as! String
                    self.completionHandler = link
                    completion(link, nil)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil, error.localizedDescription)
            }
        }
    }
    
    /*
    functions.httpsCallable("createStripeCustomer").call(["full_name": full_name, "email": profile.email]) { (response, error) in
            if let error = error {
                print(error)
            }
            if let response = (response?.data as? [String: Any]) {
                let customer_id = response["customer_id"] as! String?
                print(customer_id)
                print(publishable_key)
                Stripe.setDefaultPublishableKey(publishable_key!)
                profile.stripe_customer_id = customer_id!
                let defaults = UserDefaults.standard
                currentProfile = profile
                do {
                    try self.db.collection("Profile").document(emailAdd).setData(from: profile)
                    DispatchQueue.main.async {
                        self.switchToWelcomePage()
                    }
                } catch let error {
                    print (error)
                }
            }
        }
    }
    
    func CloudPublisher(completion: @escaping (AnyPublisher<, Error>) -> Void) {
        CloudFunctions.createStripeConnectAccount(uid: <#String#>) { [weak self] result,<#arg#>  in
            switch result {
            case .success(let authSession):
                guard let request = self?.request else {
                    return completion(Fail(error: .couldNotCreateURLRequest).eraseToAnyPublisher())
                }
                let pfPublisher = authSession.dataTaskPublisher(for: request)
                    .tryMap { data, error -> Profile in
                        let decoder = JSONDecoder()
                        let profileResponse = try decoder.decode(ProfileResponse.self, from: data)
                        return profileResponse.profile
                    }
                    .mapError { error -> Error in
                        guard let loaderError = error as? Error else {
                            return Error.couldNotFetchProfile(underlying: error)
                        }
                        return loaderError
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
                completion(pfPublisher)
            case .failure(let error):
                completion(Fail(error: error).eraseToAnyPublisher())
            }
        }
    } */
     
    @Published var completionHandler = ""
}

extension CloudManager {
    /// An error representing what went wrong in fetching a user's number of day until their birthday.
    enum Error: Swift.Error {
        case couldNotCreateURLSession(Swift.Error?)
        case couldNotCreateURLRequest
        case userHasNoProfile
        case couldNotFetchProfile(underlying: Swift.Error)
    }
}
 
*/
