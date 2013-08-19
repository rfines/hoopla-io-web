'use strict'
User = require 'models/user'
Controller = 'controllers/base/controller'

SiteView = require 'views/site-view'
HeaderView = require 'views/header-view'

module.exports = class AuthController extends Chaplin.Controller

  beforeAction: ->
    @compose 'site', SiteView
    @compose 'header', HeaderView
    url = window.location.href
    if url.indexOf('register') < 0    
      if not Chaplin.mediator.user
        if $.cookie('token') and $.cookie('user')
            user = new User()
            user.id = $.cookie('user')
            user.fetch
              success: ->
                console.log 'successful fetch of user'
                Chaplin.mediator.user = {}
                Chaplin.mediator.user = user
        else
          @goToLogin()
      else
        @goToLogin()

  goToLogin: ->
    @publishEvent '!router:route', 'login'