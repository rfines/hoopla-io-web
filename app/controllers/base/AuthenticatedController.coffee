'use strict'
User = require 'models/user'
module.exports = class AuthController extends Chaplin.Controller

  beforeAction: ->
    if not Chaplin.mediator.user
      if $.cookie('token') and $.cookie('user')
          user = new User()
          user.id = $.cookie('user')
          user.fetch
            success: ->
              Chaplin.mediator.user = user
      else
        @goToLogin()
    else
      @goToLogin()

  goToLogin: ->
    @publishEvent '!router:route', 'login'