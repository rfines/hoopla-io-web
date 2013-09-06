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
    @compositions()
    url = window.location.href
    if url.indexOf('register') < 0    
      if not Chaplin.datastore?.user
        if $.cookie('token') and $.cookie('user')
            user = new User()
            user.id = $.cookie('user')
            user.fetch
              success: =>
                Chaplin.datastore.user = user
                @publishEvent 'navigation:loggedIn'
        else
          @goToLogin()

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav, {region: 'topNav'}
    @compose 'preLoginHeader', PostLoginHeaderView, {region:'header'}  
    #@compose 'footer', Footer

  goToLogin: ->
    @publishEvent '!router:route', 'login'

  startWaiting: ->
    console.log 'start Waiting'

  stopWaiting: ->
    console.log 'stop Waiting'    

