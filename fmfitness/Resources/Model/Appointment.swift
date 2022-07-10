//
//  Appointment.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/14/22.
//

import Foundation

struct Appointment: Decodable {
    
    var uid: String = ""
    var email: String = ""
    var invoice: String = ""
    var isConfirmed: Bool = false
    var isCompleted: Bool = false
    var isPaid: Bool = false
    var isCanceled: Bool = false
    var cancelReason: String = ""
    var numAppt: Int = 0
    var nextAppointment: Date = Date()
    
    static var `default`: Appointment = Appointment(uid: "abc123",
                                                    email: "new_profile@email.com",
                                                    invoice: StripeLink.zero.rawValue,
                                                    isConfirmed: false,
                                                    isCompleted: false,
                                                    isPaid: false,
                                                    isCanceled: false,
                                                    cancelReason: "",
                                                    numAppt: 0,
                                                    nextAppointment: Date())

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

extension Appointment {
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case invoice
        case isConfirmed
        case isCompleted
        case isPaid
        case isCanceled
        case cancelReason
        case numAppt
        case nextAppointment
    }

    static func createFromJSON(_ data: Data) -> Appointment {
        let f = try? JSONDecoder().decode(Appointment.self, from: data)
        // f.finalizeInit()
        return f!
    }

    init(from decoder: Decoder, id: Int, uid: String, email: String, invoice: String, isConfirmed: Bool, isCompleted: Bool, isPaid: Bool, isCanceled: Bool, cancelReason: String, numAppt: Int, nextAppointment: Date) throws {
        // let container = try decoder.container(keyedBy: CodingKeys.self)
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
    }
}







/// A model type representing the response from the request for the current user's profile.
struct AppointmentResponse: Decodable {
    
    /// The requested user's birthdays.
    let appointment: Appointment

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appointment = try container.decode(Appointment.self, forKey: .appointments)
    }
}

extension AppointmentResponse {
    enum CodingKeys: String, CodingKey {
        case appointments
    }
}

extension AppointmentResponse {
    /// An error representing what may go wrong in processing the appointments request.
    enum Error: Swift.Error {
        /// There was no profile in the returned results.
        case noAppointmentInResult
    }
}
