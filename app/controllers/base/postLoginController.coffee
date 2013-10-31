'use strict'
User = require 'models/user'

SiteView = require 'views/site-view'
PostLoginHeaderView = require 'views/postLoginHeader'
TopNav = require 'views/topNav'
Footer = require 'views/footer'

module.exports = class PostLoginController extends Chaplin.Controller

  initialize: =>
    Chaplin.mediator.subscribe 'startWaiting', @startWaiting
    Chaplin.mediator.subscribe 'stopWaiting', @stopWaiting

  beforeAction: (params, route) ->
    _gaq.push(['_trackEvent', route.path, 'view']) if _gaq?.push
    if not Chaplin.datastore?.user
      if $.cookie('token') and $.cookie('user')
          user = new User()
          user.id = $.cookie('user')
          user.fetch
            success: =>
              Chaplin.datastore.user = user   
              @setIdentity()           
              @compositions()
              @publishEvent 'navigation:loggedIn'
            error: =>
              Chaplin.helpers.redirectTo {url: '/logout'}
      else
        @goToLogin()
    else
      @setIdentity()
      @compositions()
      @publishEvent 'navigation:loggedIn'

  setIdentity: =>
    mixpanel.identify(Chaplin.datastore.user.get('email'));
    mixpanel.people.set({
        "$email": Chaplin.datastore.user.get('email')
        "$last_login": new Date().toISOString()
    });

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav, {region: 'topNav'}
    @compose 'preLoginHeader', PostLoginHeaderView, {region:'header'}  
    @compose 'footer', Footer

  goToLogin: ->
    Chaplin.helpers.redirectTo {url: 'login'}

  startWaiting: ->
    $('.preloader').addClass('loading').show()

  stopWaiting: ->
    $('.preloader').removeClass('loading').hide()

