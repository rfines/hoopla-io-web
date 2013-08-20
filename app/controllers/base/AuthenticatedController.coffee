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
      if not Chaplin.datastore?.user
        if $.cookie('token') and $.cookie('user')
            user = new User()
            user.id = $.cookie('user')
            user.fetch
              success: ->
                Chaplin.datastore.user = user
        else
          @goToLogin()
      else
        @goToLogin()

  goToLogin: ->
    @publishEvent '!router:route', 'login'