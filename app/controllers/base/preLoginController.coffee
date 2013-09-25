SiteView = require 'views/site-view'
User = require 'models/user'

module.exports = class Controller extends Chaplin.Controller
  
  beforeAction: ->
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
                Chaplin.helpers.redirectTo {url: 'myEvents'}
              error: =>
                Chaplin.helpers.redirectTo {url: '/logout'}

  compositions: =>
    @compose 'site', SiteView
