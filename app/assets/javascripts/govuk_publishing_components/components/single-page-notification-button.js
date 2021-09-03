window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function SinglePageNotificationButton ($module) {
    this.$module = $module
  }

  SinglePageNotificationButton.prototype.init = function () {
    var xhr = new XMLHttpRequest()
    // TODO: use the real endpoint when we know what that is
    var url = '/placeholder-url'
    xhr.open('GET', url, true)
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4 && xhr.status === 200) {
        console.log(xhr.responseText)

        // TODO: check that the response has a SinglePageNotificationButton – if yes, swap the button on the page for the one returned from the server.
      }
    }.bind(this)
    xhr.send()
  }

  Modules.SinglePageNotificationButton = SinglePageNotificationButton
})(window.GOVUK.Modules)
