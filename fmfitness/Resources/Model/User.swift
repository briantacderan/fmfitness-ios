//
//  User.swift
//  fm-fitness
//
//  Created by Brian Tacderan on 5/6/22.
//

import Foundation

final class User: NSObject, Codable, Identifiable {
    let id: Int
    let email: String
    var isMember: Bool
    var outstandingBalance: Int
    
    init(
        id: Int,
        email: String,
        isMember: Bool,
        outstandingBalance: Int
    ) {
        self.id = id
        self.email = email
        self.isMember = isMember
        self.outstandingBalance = outstandingBalance
        super.init()
    }
}

extension User: NSItemProviderWriting {
    static let typeIdentifier = "com.thetacderancode.fmfitness.user"

    static var writableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler:
            @escaping (Data?, Error?) -> Void
    ) -> Progress? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            completionHandler(try encoder.encode(self), nil)
        } catch {
            completionHandler(nil, error)
        }

        return nil
    }
}

extension User: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    static func object(
        withItemProviderData data: Data,
        typeIdentifier: String
    ) throws -> User {
        let decoder = JSONDecoder()
        return try decoder.decode(User.self, from: data)
    }
}
