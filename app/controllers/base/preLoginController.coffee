SiteView = require 'views/site-view'
PreLoginHeaderView = require 'views/preLoginHeader'

module.exports = class Controller extends Chaplin.Controller
  
  beforeAction: ->
    @compose 'site', SiteView
    @compose 'preLoginHeader', PreLoginHeaderView, {region:'header'}