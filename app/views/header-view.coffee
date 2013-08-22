View = require 'views/base/view'
template = require 'templates/header'

module.exports = class HeaderView extends View
  autoRender: true
  className: 'header'
  region: 'header'
  template: template
  events:
    "click a.logout" : "logout"
    "click a.myEvents" : "redirectToEvents"
    "click a.myBusinesses" : "redirectToBusinesses"

  logout:(e)->
    e.preventDefault()
    $.removeCookie('token')
    $.removeCookie('user')
    window.location = '/'

  redirectToEvents: (e) ->
    @publishEvent '!router:route', 'demo/myEvents'

  redirectToBusinesses: (e) ->
    @publishEvent '!router:route', 'demo/myBusinesses'    