'use strict'
User = require 'models/user'

SiteView = require 'views/site-view'
HeaderView = require 'views/postLoginHeader'

module.exports = class PostLoginController extends Chaplin.Controller

  beforeAction: (params, route) ->
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
                console.log 'successful fetch of user'
        else
          @goToLogin()

  goToLogin: ->
    @publishEvent '!router:route', 'login'