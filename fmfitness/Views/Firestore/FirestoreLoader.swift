//
//  FirestoreLoader.swift
//  fmfitness
//
//  Created by Brian Tacderan on 2/8/22.
//

import Combine
import GoogleSignIn

/// An observable class to load the current user's profile.
final class FirestoreLoader: ObservableObject {
    
    var email: String = ""

    /// The scope required to read a user's data from Firestore .
    static let dataReadScope = "https://www.googleapis.com/auth/datastore"
    
    private lazy var baseUrlString: String? = { "https://firestore.googleapis.com/v1/projects/fmfitness-bb6e6/databases/(default)/documents/profile/\(self.email)"
    }()
    
    private lazy var apptUrlString: String? = { "https://firestore.googleapis.com/v1/projects/fmfitness-bb6e6/databases/(default)/documents/appointment/\(self.email)"
    }()
    
    private let profileSubject = PassthroughSubject<Profile, Error>()
    private let apptSubject = PassthroughSubject<Appointment, Error>()

    private lazy var components: URLComponents? = {
        if email != "" {
            var comps = URLComponents(string: baseUrlString!)
            return comps
        } else {
            var comps = URLComponents(string: apptUrlString!)
            return comps
        }
    }()

    private lazy var request: URLRequest? = {
        guard let components = components, let url = components.url else {
            return nil
        }
        return URLRequest(url: url)
    }()

    private lazy var session: URLSession? = {
        guard let accessToken = GIDSignIn
                .sharedInstance
                .currentUser?
                .authentication
                .accessToken else { return nil }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        return URLSession(configuration: configuration)
    }()

    private func sessionWithFreshToken(completion: @escaping (Result<URLSession, Error>) -> Void) {
        let authentication = GIDSignIn.sharedInstance.currentUser?.authentication
        authentication?.do { [self] auth, error in
            guard let token = auth?.accessToken else {
                completion(.failure(.couldNotCreateURLSession(error)))
                print(components?.url ?? "No URL available")
                return
            }
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(token)"
            ]
            let session = URLSession(configuration: configuration)
            completion(.success(session))
        }
    }

    /// Creates a `Publisher` to fetch a user's `Profile`.
    /// - parameter completion: A closure passing back the `AnyPublisher<Profile, Error>`
    /// upon success.
    /// - note: The `AnyPublisher` passed back through the `completion` closure is created with a
    /// fresh token. See `sessionWithFreshToken(completion:)` for more details.
    func profilePublisher(completion: @escaping (AnyPublisher<Profile, Error>) -> Void) {
        sessionWithFreshToken { [weak self] result in
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
    }
    
    func appointmentPublisher(completion: @escaping (AnyPublisher<Appointment, Error>) -> Void) {
        sessionWithFreshToken { [weak self] result in
            switch result {
            case .success(let authSession):
                guard let request = self?.request else {
                    return completion(Fail(error: .couldNotCreateURLRequest).eraseToAnyPublisher())
                }
                let apptPublisher = authSession.dataTaskPublisher(for: request)
                    .tryMap { data, error -> Appointment in
                        let decoder = JSONDecoder()
                        let apptResponse = try decoder.decode(AppointmentResponse.self, from: data)
                        return apptResponse.appointment
                    }
                    .mapError { error -> Error in
                        guard let loaderError = error as? Error else {
                            return Error.couldNotFetchAppointment(underlying: error)
                        }
                        return loaderError
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
                completion(apptPublisher)
            case .failure(let error):
                completion(Fail(error: error).eraseToAnyPublisher())
            }
        }
    }
}

extension FirestoreLoader {
    /// An error representing what went wrong in fetching a user's number of day until their birthday.
    enum Error: Swift.Error {
        case couldNotCreateURLSession(Swift.Error?)
        case couldNotCreateURLRequest
        case userHasNoProfile
        case couldNotFetchProfile(underlying: Swift.Error)
        case couldNotFetchAppointment(underlying: Swift.Error)
    }
}
