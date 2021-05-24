;(function (global) {
  'use strict'

  var GOVUK = global.GOVUK || {}
  GOVUK.Modules = GOVUK.Modules || {}

  GOVUK.Modules = {
    find: function (container) {
      container = container || document.documentElement

      var modules = Array.prototype.slice.call(container.querySelectorAll('[data-module]'))

      if (container.getAttribute('data-module')) {
        modules.push(container)
      }

      return modules
    },

    init: function (container) {
      var modules = this.find(container)

      for (var i = 0, l = modules.length; i < l; i++) {
        var element = modules[i]
        var moduleName = camelCaseAndCapitalise(element.getAttribute('data-module'))
        var started = element.getAttribute('data-module-started')
        var frontendModuleName = moduleName.replace('Govuk', '')

        if (
          typeof GOVUK.Modules[frontendModuleName] === 'function' &&
          GOVUK.Modules[frontendModuleName].prototype.init &&
          !started
        ) {
          new GOVUK.Modules[frontendModuleName](element).init()
          element.setAttribute('data-module-started', true)
        }
      }

      function camelCaseAndCapitalise (string) {
        return capitaliseFirstLetter(camelCase(string))
      }

      function camelCase (string) {
        return string.replace(/-([a-z])/g, function (g) {
          return g.charAt(1).toUpperCase()
        })
      }

      function capitaliseFirstLetter (string) {
        return string.charAt(0).toUpperCase() + string.slice(1)
      }
    }
  }

  global.GOVUK = GOVUK
})(window)
