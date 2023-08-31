import Foundation

struct MessageResponse: Decodable {

    // MARK: - Attributes

    let offerType: PayPalMessageResponseOfferType
    let productGroup: PayPalMessageResponseProductGroup

    let modalCloseButtonWidth: Int
    let modalCloseButtonHeight: Int
    let modalCloseButtonAvailWidth: Int
    let modalCloseButtonAvailHeight: Int
    let modalCloseButtonColor: String
    let modalCloseButtonColorType: String

    let defaultMainContent: String
    let defaultDisclaimer: String

    let genericMainContent: String
    let genericDisclaimer: String

    let logoPlaceholder: String

    let trackingData: [String: AnyCodable]

    var requestDuration: TimeInterval?

    // MARK: - Init

    init(
        offerType: PayPalMessageResponseOfferType,
        productGroup: PayPalMessageResponseProductGroup,
        defaultMainContent: String,
        defaultDisclaimer: String,
        genericMainContent: String,
        genericDisclaimer: String,
        logoPlaceholder: String,
        modalCloseButtonWidth: Int,
        modalCloseButtonHeight: Int,
        modalCloseButtonAvailWidth: Int,
        modalCloseButtonAvailHeight: Int,
        modalCloseButtonColor: String,
        modalCloseButtonColorType: String,
        trackingData: [String: AnyCodable] = [:]
    ) {
        self.offerType = offerType
        self.productGroup = productGroup
        self.defaultMainContent = defaultMainContent
        self.defaultDisclaimer = defaultDisclaimer
        self.genericMainContent = genericMainContent
        self.genericDisclaimer = genericDisclaimer
        self.logoPlaceholder = logoPlaceholder
        self.modalCloseButtonWidth = modalCloseButtonWidth
        self.modalCloseButtonHeight = modalCloseButtonHeight
        self.modalCloseButtonAvailWidth = modalCloseButtonAvailWidth
        self.modalCloseButtonAvailHeight = modalCloseButtonAvailHeight
        self.modalCloseButtonColor = modalCloseButtonColor
        self.modalCloseButtonColorType = modalCloseButtonColorType
        self.trackingData = trackingData
    }

    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let contentContainer = try container.nestedContainer(
            keyedBy: ContentContainerKeys.self,
            forKey: .content
        )

        // MARK: - Default Content Container

        let defaultContentContainer = try contentContainer.nestedContainer(
            keyedBy: ContentKeys.self,
            forKey: .def
        )

        defaultMainContent = try defaultContentContainer.decode(
            String.self,
            forKey: .main
        )
        defaultDisclaimer = try defaultContentContainer.decode(
            String.self,
            forKey: .disclaimer
        )

        // MARK: - Generic Content Container

        let genericContentContainer = try contentContainer.nestedContainer(
            keyedBy: ContentKeys.self,
            forKey: .generic
        )

        genericMainContent = try genericContentContainer.decode(
            String.self,
            forKey: .main
        )
        genericDisclaimer = try genericContentContainer.decode(
            String.self,
            forKey: .disclaimer
        )

        // MARK: - Meta Container

        let metaContainer = try container.nestedContainer(
            keyedBy: MetaKeys.self,
            forKey: .meta
        )

        offerType = try metaContainer.decode(
            PayPalMessageResponseOfferType.self,
            forKey: .offerType
        )

        productGroup = try metaContainer.decode(
            PayPalMessageResponseProductGroup.self,
            forKey: .creditProductGroup
        )

        // MARK: - Variable Container

        let variableContainer = try metaContainer.nestedContainer(
            keyedBy: VariablesKeys.self,
            forKey: .variables
        )

        logoPlaceholder = try variableContainer.decode(
            String.self,
            forKey: .inlineLogoPlaceholder
        )

        // MARK: - Modal Close Button Container

        let modalCloseButton = try metaContainer.nestedContainer(
            keyedBy: ModalCloseButton.self,
            forKey: .modalCloseButton
        )

        modalCloseButtonWidth = try modalCloseButton.decode(
            Int.self,
            forKey: .modalCloseButtonWidth
        )

        modalCloseButtonHeight = try modalCloseButton.decode(
            Int.self,
            forKey: .modalCloseButtonHeight
        )

        modalCloseButtonAvailWidth = try modalCloseButton.decode(
            Int.self,
            forKey: .modalCloseButtonAvailWidth
        )

        modalCloseButtonAvailHeight = try modalCloseButton.decode(
            Int.self,
            forKey: .modalCloseButtonAvailHeight
        )

        modalCloseButtonColor = try modalCloseButton.decode(
            String.self,
            forKey: .modalCloseButtonColor
        )

        modalCloseButtonColorType = try modalCloseButton.decode(
            String.self,
            forKey: .modalCloseButtonColorType
        )

        // MARK: - Tracking Keys

        let anyMetaContainer = try container.nestedContainer(
            keyedBy: AnyStringKey.self,
            forKey: .meta
        )
        let trackingKeys = try metaContainer.decode([String].self, forKey: .trackingKeys)

        trackingData = try {
            var trackingData: [String: AnyCodable] = [:]
            for key in trackingKeys {
                trackingData[key] = try anyMetaContainer.decode(
                    AnyCodable.self,
                    forKey: AnyStringKey(key)
                )
            }
            return trackingData
        }()
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case meta
        case content
    }

    enum MetaKeys: String, CodingKey {
        case offerType = "offer_type"
        case creditProductGroup = "credit_product_group"
        case modalCloseButton = "modal_close_button"
        case variables
        case trackingKeys = "tracking_keys"
    }

    enum ModalCloseButton: String, CodingKey {
        case modalCloseButtonWidth = "width"
        case modalCloseButtonAvailWidth = "available_width"
        case modalCloseButtonHeight = "height"
        case modalCloseButtonAvailHeight = "available_height"
        case modalCloseButtonColor = "color"
        case modalCloseButtonColorType = "color_type"
    }

    enum ContentContainerKeys: String, CodingKey {
        case def = "default"
        case generic
    }

    enum ContentKeys: String, CodingKey {
        case main
        case disclaimer
    }

    enum VariablesKeys: String, CodingKey {
        case inlineLogoPlaceholder = "inline_logo_placeholder"
    }
}
