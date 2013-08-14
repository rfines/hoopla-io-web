'use strict'

module.exports = class AuthController extends Chaplin.Controller

  beforeAction: ->
    if not Chaplin.mediator.user
      #Chaplin.mediator.redirectUrl = window.location.pathname
      @publishEvent '!router:route', 'login'