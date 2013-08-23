SiteView = require 'views/site-view'
HeaderView = require 'views/preLoginHeader'

module.exports = class Controller extends Chaplin.Controller
  
  beforeAction: ->
    @compose 'site', SiteView
    @compose 'header', HeaderView
