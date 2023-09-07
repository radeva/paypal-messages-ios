import UIKit

protocol PayPalMessageViewModelDelegate: AnyObject {
    /// Requests the delegate to perform a content refresh.
    func refreshContent()
}

// swiftlint:disable:next type_body_length
class PayPalMessageViewModel: PayPalMessageModalEventDelegate {

    // MARK: - Properties

    weak var delegate: PayPalMessageViewModelDelegate?
    weak var stateDelegate: PayPalMessageViewStateDelegate?
    weak var eventDelegate: PayPalMessageViewEventDelegate?
    weak var messageView: PayPalMessageView?

    /// This property is not being stored in the ViewModel, it will just update all related properties and compute itself on the getter.
    /// Changing its value will cause the message content being refetched *always*.
    var config: PayPalMessageConfig {
        get { makeConfig() }
        set { updateConfig(newValue) }
    }

    var environment: Environment {
        didSet { queueUpdate(from: oldValue, to: environment) }
    }

    var clientID: String {
        didSet { queueUpdate(from: oldValue, to: clientID) }
    }

    var merchantID: String? {
        didSet { queueUpdate(from: oldValue, to: merchantID) }
    }

    var partnerAttributionID: String? {
        didSet { queueUpdate(from: oldValue, to: partnerAttributionID) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var placement: PayPalMessagePlacement? {
        didSet { queueUpdate(from: oldValue, to: placement) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var amount: Double? {
        didSet { queueUpdate(from: oldValue, to: amount) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var offerType: PayPalMessageOfferType? {
        didSet { queueUpdate(from: oldValue, to: offerType) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var buyerCountry: String? {
        didSet { queueUpdate(from: oldValue, to: buyerCountry) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var logoType: PayPalMessageLogoType {
        didSet { queueUpdate(from: oldValue, to: logoType) }
    }

    /// Changing its value will not cause the message content being refetched. It will only trigger an UI update.
    var color: PayPalMessageColor {
        didSet { queueUpdate(from: oldValue, to: color, requiresFetch: false) }
    }

    /// Changing its value will not cause the message content being refetched. It will only trigger an UI update.
    var alignment: PayPalMessageTextAlignment {
        didSet { queueUpdate(from: oldValue, to: alignment, requiresFetch: false) }
    }

    var ignoreCache: Bool {
        didSet { queueUpdate(from: oldValue, to: ignoreCache) }
    }

    var stageTag: String? {
        didSet { queueUpdate(from: oldValue, to: stageTag) }
    }

    var devTouchpoint: Bool {
        didSet { queueUpdate(from: oldValue, to: devTouchpoint) }
    }

    /// returns the parameters for the style and content the message's Attributed String according to the server response
    var messageParameters: PayPalMessageViewParameters? { makeViewParameters() }

    // MARK: - Private Properties
    /// used to avoid property update related requests from being executed when there's a config requesting a fetch
    private var fetchMessageContentPending = false

    /// Config update queue debounce time interval
    private let queueTimeInterval: TimeInterval = 0.001

    /// Timer used to batch update multiple fields via debounce
    private var queuedTimer: Timer?

    /// stores the last message response for the fetch
    private var messageResponse: MessageResponse?

    /// Datetime when the last render occurred
    private var renderStart: Date?

    /// sends the API request
    private let requester: MessageRequestable

    /// helper class to build the parameters for the PayPalMessageView
    private let parameterBuilder: PayPalMessageViewParametersBuilder

    /// obtains the Merchant Hash and requests it if necessary
    private let merchantProfileProvider: MerchantProfileHashGetable

    /// modal instance attached to the message
    private var modal: PayPalMessageModal?

    /// Tracking logger
    let logger: ComponentLogger

    // MARK: - Inits and Setters

    init(
        config: PayPalMessageConfig,
        requester: MessageRequestable = MessageRequest(),
        parameterBuilder: PayPalMessageViewParametersBuilder = PayPalMessageViewParametersBuilder(),
        merchantProfileProvider: MerchantProfileHashGetable = MerchantProfileProvider(),
        delegate: PayPalMessageViewModelDelegate? = nil,
        eventDelegate: PayPalMessageViewEventDelegate? = nil,
        stateDelegate: PayPalMessageViewStateDelegate? = nil,
        messageView: PayPalMessageView? = nil
    ) {
        self.clientID = config.data.clientID
        self.merchantID = config.data.merchantID
        self.partnerAttributionID = config.data.partnerAttributionID
        self.environment = config.data.environment
        self.amount = config.data.amount
        self.placement = config.data.placement
        self.offerType = config.data.offerType
        self.buyerCountry = config.data.buyerCountry
        self.color = config.style.color
        self.logoType = config.style.logoType
        self.alignment = config.style.textAlignment
        self.ignoreCache = config.data.ignoreCache
        self.stageTag = config.data.stageTag
        self.devTouchpoint = config.data.devTouchpoint

        self.requester = requester
        self.parameterBuilder = parameterBuilder
        self.merchantProfileProvider = merchantProfileProvider
        self.delegate = delegate
        self.eventDelegate = eventDelegate
        self.stateDelegate = stateDelegate
        self.messageView = messageView

        self.logger = Logger.createMessageLogger(
            environment: environment,
            clientID: clientID,
            merchantID: merchantID,
            partnerAttributionID: partnerAttributionID,
            offerType: offerType,
            amount: amount,
            placement: placement,
            buyerCountryCode: buyerCountry,
            styleColor: color,
            styleLogoType: logoType,
            styleTextAlign: alignment
        )
    }

    deinit {}

    private func updateConfig(_ config: PayPalMessageConfig) {
        self.amount = config.data.amount
        self.placement = config.data.placement
        self.offerType = config.data.offerType
        self.buyerCountry = config.data.buyerCountry
        self.color = config.style.color
        self.logoType = config.style.logoType
        self.alignment = config.style.textAlignment
        self.ignoreCache = config.data.ignoreCache
        self.stageTag = config.data.stageTag
        self.devTouchpoint = config.data.devTouchpoint
    }

    // MARK: - Fetch Methods

    private func queueUpdate<T: Equatable>(
        from oldValue: T,
        to newValue: T,
        requiresFetch: Bool = true
    ) {
        guard oldValue != newValue else { return }

        return queueMessageContentUpdate(requiresFetch: requiresFetch)
    }

    /// When the message is being fetch from a Property update, it considers whether an update is not being currently executed or requested
    func queueMessageContentUpdate(requiresFetch: Bool = true, fireImmediately: Bool = false) {
        renderStart = Date()

        if requiresFetch {
            self.fetchMessageContentPending = true
        }

        queuedTimer?.invalidate()

        queuedTimer = Timer.scheduledTimer(
            withTimeInterval: queueTimeInterval,
            repeats: false
        ) { _ in
            if self.fetchMessageContentPending {
                self.fetchMessageContent()
                self.fetchMessageContentPending = false
            } else {
                self.delegate?.refreshContent()
            }
        }

        if fireImmediately {
            queuedTimer?.fire()
        }
    }

    /// Refreshes the Message content only if there's a new amount or logo type set
    private func fetchMessageContent() {
        if let stateDelegate, let messageView {
            stateDelegate.onLoading(messageView)
        }

        merchantProfileProvider.getMerchantProfileHash(environment: environment, clientID: clientID) { [weak self] profileHash in
            guard let self else { return }

            let parameters = self.makeRequestParameters(merchantProfileHash: profileHash)

            self.requester.fetchMessage(parameters: parameters) { [weak self] result in
                switch result {
                case .success(let response):
                    self?.onMessageRequestReceived(response: response)

                case .failure(let error):
                    self?.onMessageRequestFailed(error: error)
                }
            }
        }
    }

    // MARK: - Fetch Helpers

    private func onMessageRequestFailed(error: PayPalMessageError) {
        messageResponse = nil

        let errorDescription = error.description ?? ""
        self.logger.addEvent(.messageError(
            errorName: "\(error)",
            errorDescription: errorDescription
        ))

        if let stateDelegate, let messageView {
            stateDelegate.onError(messageView, error: error)
        }

        delegate?.refreshContent()
    }

    private func onMessageRequestReceived(response: MessageResponse) {
        messageResponse = response
        logger.dynamicData = response.trackingData

        if let stateDelegate, let messageView {
            stateDelegate.onSuccess(messageView)
        }

        delegate?.refreshContent()

        // How to get renderDuration?
        // Is this the correct way to get requestDuration?
        logger.addEvent(.messageRender(
            // Convert to milliseconds
            renderDuration: Int((renderStart?.timeIntervalSinceNow ?? 1 / 1000) * -1000),
            requestDuration: Int((messageResponse?.requestDuration ?? 1 / 1000) * -1000)
        ))

        modal?.setConfig(makeModalConfig())

        log(.info, "onMessageRequestReceived is \(String(describing: response.defaultMainContent))")
    }

    // MARK: - Message Request Builder

    private func makeRequestParameters(merchantProfileHash: String?) -> MessageRequestParameters {
        .init(
            environment: environment,
            clientID: clientID,
            merchantID: merchantID,
            partnerAttributionID: partnerAttributionID,
            logoType: logoType,
            buyerCountry: buyerCountry,
            placement: placement,
            amount: amount,
            offerType: offerType,
            merchantProfileHash: merchantProfileHash,
            ignoreCache: ignoreCache,
            devTouchpoint: devTouchpoint,
            stageTag: stageTag
        )
    }

    // MARK: - Message Styling Builders

    private func makeViewParameters() -> PayPalMessageViewParameters? {
        guard let response = messageResponse else { return nil }

        return parameterBuilder
            .makeParameters(
                message: response.defaultMainContent,
                linkDescription: response.defaultDisclaimer,
                logoPlaceholder: response.logoPlaceholder,
                logoType: logoType,
                payPalAlignment: alignment,
                payPalColor: color,
                productGroup: response.productGroup
            )
    }

    // MARK: - Config Exporter

    private func makeConfig() -> PayPalMessageConfig {
        let config = PayPalMessageConfig(
            data: .init(
                clientID: clientID,
                amount: amount,
                placement: placement,
                offerType: offerType,
                environment: environment
            ),
            style: .init(
                logoType: logoType,
                color: color,
                textAlignment: alignment
            )
        )
        config.data.merchantID = merchantID
        config.data.partnerAttributionID = partnerAttributionID
        config.data.buyerCountry = buyerCountry
        config.data.ignoreCache = ignoreCache
        config.data.stageTag = stageTag
        config.data.devTouchpoint = devTouchpoint

        return config
    }

    // MARK: - Modal Methods

    private func makeModalConfig() -> PayPalMessageModalConfig {
        let offerType = PayPalMessageOfferType(rawValue: messageResponse?.offerType.rawValue ?? "")

        var color: UIColor?
        if let colorString = messageResponse?.modalCloseButtonColor {
            color = UIColor(hexString: colorString)
        }

        let modalCloseButton = ModalCloseButtonConfig(
            width: messageResponse?.modalCloseButtonWidth,
            height: messageResponse?.modalCloseButtonHeight,
            availableWidth: messageResponse?.modalCloseButtonAvailWidth,
            availableHeight: messageResponse?.modalCloseButtonAvailHeight,
            color: color,
            colorType: messageResponse?.modalCloseButtonColorType
        )

        let config = PayPalMessageModalConfig(
            data: .init(
                clientID: clientID,
                amount: amount,
                // currency: currency, TODO: Implement?
                placement: placement,
                offerType: offerType,
                modalCloseButton: modalCloseButton,
                environment: environment
            )
        )
        // Partner options
        config.data.merchantID = merchantID
        config.data.partnerAttributionID = partnerAttributionID
        // Non-standard options
        config.data.buyerCountry = buyerCountry
        config.data.modalCloseButton = modalCloseButton
        // Dev options
        config.data.ignoreCache = ignoreCache
        config.data.devTouchpoint = devTouchpoint
        config.data.stageTag = stageTag

        return config
    }

    func showModal() {
        if let eventDelegate, let messageView {
            eventDelegate.onClick(messageView)
        }

        logger.addEvent(.messageClick(
            linkName: messageResponse?.defaultDisclaimer ?? "Learn More",
            linkSrc: "learn_more"
        ))

        if modal == nil {
            modal = PayPalMessageModal(
                config: makeModalConfig(),
                eventDelegate: self
            )
        }

        modal?.show()
    }

    // MARK: Modal Event Delegate Functions

    func onClick(_ modal: PayPalMessageModal, data: PayPalMessageModalClickData) {
        if let eventDelegate, let messageView, data.linkName.contains("Apply Now") {
            eventDelegate.onApply(messageView)
        }
    }

    func onCalculate(_ modal: PayPalMessageModal, data: PayPalMessageModalCalculateData) {}
    func onShow(_ modal: PayPalMessageModal) {}
    func onClose(_ modal: PayPalMessageModal) {}
}
// swiftlint:disable:this file_length