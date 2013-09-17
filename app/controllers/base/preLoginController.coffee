SiteView = require 'views/site-view'
PreLoginHeaderView = require 'views/preLoginHeader'
TopNav = require 'views/topNav'
Footer = require 'views/footer'
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
                @publishEvent '!router:route', 'myEvents'

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav, {region: 'topNav'}
    @compose 'preLoginHeader', PreLoginHeaderView, {region:'header'}  
    @compose 'footer', Footer