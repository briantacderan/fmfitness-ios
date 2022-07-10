//
//  TodoItem.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
//

import Foundation

final class TodoItem: NSObject, Codable, Identifiable {
    
    var id: Int
    var uid: String = ""
    var email: String
    var invoice: String
    var isConfirmed: Bool
    var isCompleted: Bool
    var isPaid: Bool
    var isCanceled: Bool
    var cancelReason: String
    var numAppt: Int
    var nextAppointment: Date
    
    init(
        id: Int,
        uid: String,
        email: String,
        invoice: String,
        isConfirmed: Bool,
        isCompleted: Bool,
        isPaid: Bool,
        isCanceled: Bool,
        cancelReason: String,
        numAppt: Int,
        nextAppointment: Date
    ) {
        self.id = id
        self.uid = uid
        self.email = email
        self.invoice = invoice
        self.isConfirmed = isConfirmed
        self.isCompleted = isCompleted
        self.isPaid = isPaid
        self.isCanceled = isCanceled
        self.cancelReason = cancelReason
        self.numAppt = numAppt
        self.nextAppointment = nextAppointment
        super.init()
    }
    
    enum StripeLink: String, CaseIterable, Identifiable {
        case zero = "$0"
        case hundred = "$100"
        //case hundred = "https://checkout.stripe.com/pay/cs_live_a18agieXo53jtxINTkyulMRiO4j85TzXfGhOxtY7SyptfkWMMUFzZIxfMm#fidkdWxOYHwnPyd1blppbHNgWjA0TVQ9TDdERlI1TDJTZnx0PElzUDJMS1FXfGxBPFQ3REZEdURQb2tCPXNdbEg3M0N9PDFvaE5mTTRramNMR19PbF1nTUs8YEdvajYyXUNEXUQ3cUE8aX11NTVxdGRNMn1jdCcpJ3VpbGtuQH11anZgYUxhJz8nPERUPX1AZEBsPVM1NG1gZEBAJykndXdgaWpkYUNqa3EnPydGbWRud2QlVWBxZm0neCUl"
        case hundredFifty = "$150"
        case twoHundred = "$200"
        case threeHundred = "$300"

        var id: String { rawValue }
    }
}

extension TodoItem: NSItemProviderWriting {
    static let typeIdentifier = "com.thetacderancode.fm-fitness.todoItem"

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

extension TodoItem: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    static func object(
        withItemProviderData data: Data,
        typeIdentifier: String
    ) throws -> TodoItem {
        let decoder = JSONDecoder()
        return try decoder.decode(TodoItem.self, from: data)
    }
}

