import Foundation
@testable import PayPalMessages
import XCTest

final class MerchantProfileProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()

        UserDefaults.standard.removeObject(
            forKey: UserDefaults.Key.merchantProfileData.rawValue
        )
    }

    // MARK: - Tests

    // simulates the first hash request
    func testFirstHashRequest() {
        let requestMock = MerchantProfileRequestMock(scenario: .success)
        let provider = MerchantProfileProvider(merchantProfileRequest: requestMock)

        // no requests should have been performed yet
        XCTAssertEqual(requestMock.requestsPerformed, 0)

        // retrieve hash and check requests performed
        provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
            XCTAssertNotNil(hash)
            XCTAssertEqual(requestMock.requestsPerformed, 1)
        }
    }

    // simulates a second hash request -- returns the cached value
    func testSuccessCachedHashRequest() {
        let requestMock = MerchantProfileRequestMock(scenario: .success)
        let provider = MerchantProfileProvider(merchantProfileRequest: requestMock)

        // retrieve hash and check requests performed
        provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
            let firstHash = hash
            XCTAssertNotNil(hash)
            XCTAssertEqual(requestMock.requestsPerformed, 1)

            // after retrieving it again, the hash should not be empty -- and no new request performed
            provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { secondHash in
                XCTAssertEqual(firstHash, secondHash)
                XCTAssertEqual(requestMock.requestsPerformed, 1)
            }
        }
    }

    // simulates a request with soft ttl expired, returns value but performs additional request
    func testTtlSoftExpired() {
        let requestMock = MerchantProfileRequestMock(scenario: .ttlSoftExpired)
        let provider = MerchantProfileProvider(merchantProfileRequest: requestMock)

        // perform first request
        provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
            let firstHash = hash
            XCTAssertNotNil(hash)
            XCTAssertEqual(requestMock.requestsPerformed, 1)

            // perform another request, cached value will be returned but another request perfoms on background
            provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { secondHash in
                XCTAssertEqual(firstHash, secondHash)
                XCTAssertEqual(requestMock.requestsPerformed, 2)
            }
        }
    }

    // simulates a request with ttl expired
    func testTtlHardExpired() {
        let requestMock = MerchantProfileRequestMock(scenario: .ttlHardExpired)
        let provider = MerchantProfileProvider(merchantProfileRequest: requestMock)

        // perform first request
        provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
            let firstHash = hash
            XCTAssertNotNil(hash)
            XCTAssertEqual(requestMock.requestsPerformed, 1)

            // perform another request, new request performed
            provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { secondHash in
                XCTAssertNotEqual(firstHash, secondHash)
                XCTAssertEqual(requestMock.requestsPerformed, 2)
            }
        }
    }


    // simulates a request with response error, won't return value since it expired
    func testResponseError() {
        let requestMock = MerchantProfileRequestMock(scenario: .cacheFlowDisabled)
        let provider = MerchantProfileProvider(merchantProfileRequest: requestMock)

        // perform first request -- null expected
        provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
            XCTAssertNil(hash)

            // perform another request, null expected and used cached result
            provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
                XCTAssertNil(hash)
                XCTAssertEqual(requestMock.requestsPerformed, 1)
            }
        }
    }

    // simulates a request with network error, won't return value since it expired
    func testNetworkError() {
        let requestMock = MerchantProfileRequestMock(scenario: .networkError)
        let provider = MerchantProfileProvider(merchantProfileRequest: requestMock)

        // perform first request -- null expected
        provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
            XCTAssertNil(hash)

            // perform another request, null expected and new request performed
            provider.getMerchantProfileHash(environment: .live, clientID: "testclientid") { hash in
                XCTAssertNil(hash)
                XCTAssertEqual(requestMock.requestsPerformed, 2)
            }
        }
    }
}
