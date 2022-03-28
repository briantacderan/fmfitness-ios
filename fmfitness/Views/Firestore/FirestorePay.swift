//
//  FirestorePay.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/13/22.
//

/*

import StripeApplePay
import PassKit

class CheckoutViewController: UIViewController, ApplePayContextDelegate {
    let applePayButton: PKPaymentButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Only offer Apple Pay if the customer can pay with it
        applePayButton.isHidden = !StripeAPI.deviceSupportsApplePay()
        applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
    }

    func handleApplePayButtonTapped() {
        let merchantIdentifier = "merchant.com.your_app_name"
        let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "US", currency: "USD")

        // Configure the line items on the payment request
        paymentRequest.paymentSummaryItems = [
            // The final line should represent your company;
            // it'll be prepended with the word "Pay" (that is, "Pay iHats, Inc $50")
            PKPaymentSummaryItem(label: "iHats, Inc", amount: 50.00),
        ]
        
        // Initialize an STPApplePayContext instance
        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
            // Present Apple Pay payment sheet
            applePayContext.presentApplePay(on: self)
        } else {
            // There is a problem with your Apple Pay configuration
        }
    }
}

extension CheckoutViewController {
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: StripeAPI.PaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        let clientSecret = ... // Retrieve the PaymentIntent client secret from your backend (see Server-side step above)
        // Call the completion block with the client secret or an error
        completion(clientSecret, error);
    }

    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPPaymentStatus, error: Error?) {
          switch status {
        case .success:
            // Payment succeeded, show a receipt view
            break
        case .error:
            // Payment failed, show the error
            break
        case .userCancellation:
            // User canceled the payment
            break
        @unknown default:
            fatalError()
        }
    }
}

*/
