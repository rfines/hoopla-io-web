SiteView = require 'views/site-view'
Controller = require 'controllers/base/preLoginController'
HomePageView = require 'views/home'
BlogView = require 'views/blog'
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
    
  blog: (params)->
    template = require('templates/blog')
    @view = new BlogView
      region:'main'

  error: (params) ->
    template = require('templates/error')
    @view = new ErrorView
      region: 'main'
      

  startWaiting: ->
    $('.preloader').css('margin-top': '-60px')
    $('.preloader').addClass('loading').show()

  stopWaiting: ->
    $('.preloader').removeClass('loading').hide()      