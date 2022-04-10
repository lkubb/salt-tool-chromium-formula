.. _policies.example:

Example Policies
================

.. code-block:: yaml

  recommended:
    AdsSettingForIntrusiveAdsSites: 2
    AutofillCreditCardEnabled: false
    BlockThirdPartyCookies: true
    BookmarkBarEnabled: true
    BrowserAddPersonEnabled: false
    BrowserGuestModeEnabled: false
    BrowserNetworkTimeQueriesEnabled: false
    BrowserSignin: 0
    BuiltInDnsClientEnabled: false
    CloudPrintProxyEnabled: false
    CloudPrintSubmitEnabled: false
    CloudReportingEnabled: false
    DefaultCookiesSetting: 1
    DefaultGeolocationSetting: 3
    DefaultInsecureContentSetting: 2
    DefaultNotificationsSetting: 3
    DefaultPluginsSetting: 2
    DefaultPopupsSetting: 2
    DisablePrintPreview: true
    EnableMediaRouter: false
    ImportBookmarks: false
    MetricsReportingEnabled: false
    PaymentMethodQueryEnabled: false
    PrintHeaderFooter: false
    PrintingBackgroundGraphicsDefault: disabled
    PromotionalTabsEnabled: false
    RelaunchNotification: 2
    RestoreOnStartup: 1
    SSLErrorOverrideAllowed: false
    SSLVersionMin: tls1.2
    SafeBrowsingExtendedReportingEnabled: false
      # 0 disable, 2 extended. security > privacy => 1, else 0
    SafeBrowsingProtectionLevel: 1
    SafeSitesFilterBehavior: 0
    SearchSuggestEnabled: false
    ShowFullUrlsInAddressBar: true
    SyncDisabled: true
    UrlKeyedAnonymizedDataCollectionEnabled: false
    UserFeedbackAllowed: false
