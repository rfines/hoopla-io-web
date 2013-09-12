View = require 'views/base/view'
template = require 'templates/postLoginHeader'

module.exports = class HeaderView extends View
  autoRender: true
  className: 'header'
  region: 'header'
  template: template
  events:
    "click a.logout" : "logout"
    "click a.myEvents" : "redirectToEvents"
    "click a.myBusinesses" : "redirectToBusinesses"
    "click a.media" : "redirectToMedia"
    "click a.myApps" : "redirectToApps"
    "click a.account" : "redirectToAccount"
  listen:
    '!router:route mediator': 'activateNav'
    'activateNav mediator': 'activateNav'    

  activateNav: (route) ->
    @$el.find('.active').removeClass('active')
    if route is 'myBusinesses'
      @$el.find('.myBusinesses').addClass('active')
    if route is 'myEvents'
      @$el.find('.myEvents').addClass('active')

  logout:(e)->
    @publishEvent '!router:route', 'logout'

  redirectToEvents: (e) ->
    @publishEvent '!router:route', 'myEvents'

  redirectToBusinesses: (e) ->
    @publishEvent '!router:route', 'myBusinesses'    

  redirectToMedia: (e) ->
    @publishEvent '!router:route', 'media'

  redirectToApps: (e) ->
    @publishEvent '!router:route', 'myWidgets'

  redirectToAccount: (e) ->
    @publishEvent '!router:route', 'account'  