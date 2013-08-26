SiteView = require 'views/site-view'
PreLoginHeaderView = require 'views/preLoginHeader'
TopNav = require 'views/topNav'
Footer = require 'views/footer'

module.exports = class Controller extends Chaplin.Controller
  
  beforeAction: ->
    @compositions()

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav, {region: 'topNav'}
    @compose 'preLoginHeader', PreLoginHeaderView, {region:'header'}  
    @compose 'footer', Footer