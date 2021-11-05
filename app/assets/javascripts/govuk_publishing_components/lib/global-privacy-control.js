(function (root) {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  var GPC_COOKIE_NAME = '_globalPrivacyControl'
  var DNT_COOKIE_NAME = '_doNotTrack'

  window.GOVUK.globalPrivacyControlFeatureEnabled = function() {
    return
      stringToBool(window.experimental_GOVUK_GlobalPrivacyControlSupport) ||
      stringToBool(window.experimental_GOVUK_DoNotTrackSupport) ||
      false
  }

  window.GOVUK.globalPrivacyControlValue = function () {
    if (stringToBool(window.experimental_GOVUK_GlobalPrivacyControlSupport)) {
      if (typeof navigator.globalPrivacyControl !== 'undefined') {
        return navigator.globalPrivacyControl
      }
      else if (window.GOVUK.cookie(GPC_COOKIE_NAME) !== null) {
        return cookieStrToBool(GPC_COOKIE_NAME)
      }
    }
    else if (stringToBool(window.experimental_GOVUK_DoNotTrackSupport)) {
      if (typeof navigator.doNotTrack !== 'undefined') {
        return stringToBool(navigator.doNotTrack)
      }
      else if (window.GOVUK.cookie(DNT_COOKIE_NAME) !== null) {
        return cookieStrToBool(DNT_COOKIE_NAME)
      }
    }

    return false
  }

  function stringToBool (s) {
    // Checks for case insensitive "true" or "1" or "on"
    // and ignores surrounding spaces.
    var strToBool = /^\s*(true|1|on)\s*$/i
    return strToBool.test(s)
  }

  function cookieStrToBool (c) {
    // Gets the cookie's value and converts to a boolean.
    // If cookie doesn't exist, will return false
    return stringToBool(window.GOVUK.cookie(c))
  }
}(window))
