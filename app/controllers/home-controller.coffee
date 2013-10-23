SiteView = require 'views/site-view'
Controller = require 'controllers/base/preLoginController'
HomePageView = require 'views/home'
ErrorView = require 'views/error'

module.exports = class HomeController extends Controller

  initialize: =>
    Chaplin.mediator.subscribe 'startWaiting', @startWaiting
    Chaplin.mediator.subscribe 'stopWaiting', @stopWaiting

  home: (params) ->
    template = require('templates/home')
    @view = new HomePageView
      region:'main'
      showLogin : params?.showLogin
      showForgotPassword : params?.showForgotPassword
      showResetPassword: params?.showResetPassword
      signup : params?.signup
      goto: params?.goto

  compositions: =>
    @compose 'site', SiteView

  error: (params) ->
    template = require('templates/error')
    @view = new ErrorView
      region: 'main'
      

  startWaiting: ->
    $('.preloader').css('margin-top': '-60px')
    $('.preloader').addClass('loading').show()

  stopWaiting: ->
    $('.preloader').css('margin-top': '0px')
    $('.preloader').removeClass('loading').hide()      