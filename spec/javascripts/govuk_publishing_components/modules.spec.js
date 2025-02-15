/* eslint-env jasmine, jquery */

var $ = window.jQuery

describe('GOVUK Modules', function () {
  'use strict'
  var GOVUK = window.GOVUK

  it('finds modules in body', function () {
    var module = $('<div data-module="a-module"></div>')
    $('body').append(module)

    expect(GOVUK.modules.find().length).toBe(1)
    expect(GOVUK.modules.find().eq(0).is('[data-module="a-module"]')).toBe(true)
    module.remove()
  })

  it('finds modules in head', function () {
    var module = $('<meta name="fake-meta" content="blah" data-module="a-module">')
    $('head').append(module)

    expect(GOVUK.modules.find().length).toBe(1)
    expect(GOVUK.modules.find().eq(0).is('[data-module="a-module"]')).toBe(true)
    module.remove()
  })

  it('finds modules in a page', function () {
    var headModule = $('<meta name="fake-meta" content="blah" data-module="head-module">')
    $('head').append(headModule)

    var bodyModule = $('<div data-module="body-module"></div>')
    $('body').append(bodyModule)

    expect(GOVUK.modules.find().length).toBe(2)
    expect(GOVUK.modules.find().eq(0).is('[data-module="head-module"]')).toBe(true)
    expect(GOVUK.modules.find().eq(1).is('[data-module="body-module"]')).toBe(true)
    headModule.remove()
    bodyModule.remove()
  })

  it('finds modules in a container', function () {
    var module = $('<div data-module="a-module"></div>')
    var container = $('<div></div>').append(module)

    expect(GOVUK.modules.find(container).length).toBe(1)
    expect(GOVUK.modules.find(container).eq(0).data('module')).toBe('a-module')
    container.remove()
  })

  it('finds modules that are a container', function () {
    var module = $('<div data-module="a-module"></div>')
    var container = $('<div data-module="container-module"></div>').append(module)

    expect(GOVUK.modules.find(container).length).toBe(2)
    expect(GOVUK.modules.find(container).eq(0).data('module')).toBe('container-module')
    expect(GOVUK.modules.find(container).eq(1).data('module')).toBe('a-module')
    container.remove()
  })

  it('can find a module with a DOM element input', function () {
    var container = $('<div data-module="container-module"></div>')

    expect(GOVUK.modules.find(container[0]).length).toBe(1)
    expect(GOVUK.modules.find(container).eq(0).data('module')).toBe('container-module')
  })

  describe('when modules exist', function () {
    var container
    var callbackLegacyModule
    var callbackGovukModule
    var callbackFrontendModule
    var callbackGemFrontendModule

    beforeEach(function () {
      callbackLegacyModule = jasmine.createSpy()
      callbackGovukModule = jasmine.createSpy()
      callbackFrontendModule = jasmine.createSpy()
      callbackGemFrontendModule = jasmine.createSpy()

      // GOV.UK Frontend Toolkit Modules
      GOVUK.Modules.LegacyTestAlertModule = function () {
        var that = this
        that.start = function (element) {
          callbackLegacyModule(element)
        }
      }

      // GOV.UK Publishing Modules
      function GovukTestAlertModule () { }
      GovukTestAlertModule.prototype.start = function (element) {
        callbackGovukModule(element)
      }
      GOVUK.Modules.GovukTestAlertModule = GovukTestAlertModule

      // GOV.UK Frontend Modules
      function TestAlertFrontendModule (element) {
        this.element = element
      }
      TestAlertFrontendModule.prototype.init = function () {
        callbackFrontendModule(this.element)
      }
      GOVUK.Modules.TestAlertFrontendModule = TestAlertFrontendModule

      // GOV.UK Gem Frontend Modules
      function GemTestAlertFrontendModule (element) {
        this.element = element
      }
      GemTestAlertFrontendModule.prototype.init = function () {
        callbackGemFrontendModule(this.element)
      }
      GOVUK.Modules.GemTestAlertFrontendModule = GemTestAlertFrontendModule

      // GOV.UK Publishing Module with a GOVUK Frontend counterpart
      function GovukTestAlertPublishingAndFrontendModule () { }
      GovukTestAlertPublishingAndFrontendModule.prototype.start = function (element) {
        callbackGovukModule(element)
      }
      GOVUK.Modules.GovukTestAlertPublishingAndFrontendModule = GovukTestAlertPublishingAndFrontendModule

      // GOV.UK Frontend Module with a GOVUK Publishing Module counterpart
      function TestAlertPublishingAndFrontendModule (element) {
        this.element = element
      }
      TestAlertPublishingAndFrontendModule.prototype.init = function () {
        callbackFrontendModule(this.element)
      }
      GOVUK.Modules.TestAlertPublishingAndFrontendModule = TestAlertPublishingAndFrontendModule

      // GOV.UK Frontend Module that depends on cookies to start and delays
      function TestCookieDependencyModule (element) {
        this.element = element
      }
      TestCookieDependencyModule.prototype.init = function () {
        this.startModule = this.startModule.bind(this)
        window.addEventListener('cookie-consent', this.startModule)
      }
      TestCookieDependencyModule.prototype.startModule = function () {
        window.removeEventListener('cookie-consent', this.startModule)
        callbackFrontendModule(this.element)
      }
      GOVUK.Modules.TestCookieDependencyModule = TestCookieDependencyModule

      container = $('<div></div>')
    })

    afterEach(function () {
      delete GOVUK.Modules.LegacyTestAlertModule
      delete GOVUK.Modules.GovukTestAlertModule
      delete GOVUK.Modules.TestAlertFrontendModule
      delete GOVUK.Modules.GemTestAlertFrontendModule
      delete GOVUK.Modules.GovukTestAlertPublishingAndFrontendModule
      delete GOVUK.Modules.TestAlertPublishingAndFrontendModule
      delete GOVUK.Modules.TestCookieDependencyModule

      container.remove()
    })

    it('starts modules within a container', function () {
      var legacyModule = $('<div data-module="legacy-test-alert-module"></div>')
      var publishingModule = $('<div data-module="govuk-test-alert-module"></div>')
      var frontendModule = $('<div data-module="test-alert-frontend-module"></div>')
      var publishingAndFrontendModule = $('<div data-module="govuk-test-alert-publishing-and-frontend-module"></div>')
      container.append(legacyModule).append(publishingModule).append(frontendModule).append(publishingAndFrontendModule)

      GOVUK.modules.start(container)
      expect(callbackLegacyModule).toHaveBeenCalled()
      expect(callbackGovukModule).toHaveBeenCalled()
      expect(callbackFrontendModule).toHaveBeenCalled()
    })

    it('does not start modules that are already started', function () {
      var module = $('<div data-module="legacy-test-alert-module"></div>')
      container.append(module)

      GOVUK.modules.start(module)
      GOVUK.modules.start(module)
      expect(callbackLegacyModule.calls.count()).toBe(1)
    })

    it('passes the HTML element to the module’s start method', function () {
      var module = $('<div data-module="legacy-test-alert-module"></div>')
      container.append(module)

      GOVUK.modules.start(container)

      var args = callbackLegacyModule.calls.argsFor(0)
      expect(args[0].is('div[data-module="legacy-test-alert-module"]')).toBe(true)
    })

    it('starts all modules that are on the page', function () {
      var modules = $(
        '<div data-module="legacy-test-alert-module"></div>' +
        '<strong data-module="legacy-test-alert-module"></strong>' +
        '<span data-module="legacy-test-alert-module"></span>' +
        '<div data-module="govuk-test-alert-module"></div>' +
        '<div data-module="govuk-test-alert-publishing-and-frontend-module"></div>' +
        '<div data-module="test-alert-frontend-module"></div>'
      )

      $('body').append(modules)
      GOVUK.modules.start()
      expect(callbackLegacyModule.calls.count()).toBe(3)
      expect(callbackGovukModule.calls.count()).toBe(2)
      expect(callbackFrontendModule.calls.count()).toBe(1)
      modules.remove()
    })

    it('starts multiple modules on a single element', function () {
      var modules = $(
        '<div data-module="test-alert-frontend-module gem-test-alert-frontend-module"></div>'
      )

      $('body').append(modules)
      GOVUK.modules.start()
      expect(callbackGemFrontendModule.calls.count()).toBe(1)
      expect(callbackFrontendModule.calls.count()).toBe(1)
      modules.remove()
    })

    it('starts delayed modules once cookies have been consented', function () {
      var module = $('<div data-module="test-cookie-dependency-module"></div>')
      container.append(module)
      $('body').append(container)

      GOVUK.modules.start(container)
      expect(callbackFrontendModule.calls.count()).toBe(0)
      window.GOVUK.triggerEvent(window, 'cookie-consent')
      expect(callbackFrontendModule.calls.count()).toBe(1)
    })

    it('starts multiple delayed modules once cookies have been consented', function () {
      var module1 = $('<div data-module="test-cookie-dependency-module"></div>')
      var module2 = $('<div data-module="test-cookie-dependency-module"></div>')
      container.append(module1)
      container.append(module2)
      $('body').append(container)

      GOVUK.modules.start(container)
      expect(callbackFrontendModule.calls.count()).toBe(0)
      window.GOVUK.triggerEvent(window, 'cookie-consent')
      expect(callbackFrontendModule.calls.count()).toBe(2)
    })
  })
})
