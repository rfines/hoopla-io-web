View = require 'views/base/view'
template = require 'templates/postLoginHeader'

module.exports = class HeaderView extends View
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
  attach: ()->
    super()
    url = @getCurrentUrl()
    @activateNav(url)

  activateNav: (route) ->
    if route?.indexOf 'promote' > 0
      @updatePageTitle("Promote Event")
    if route is 'myBusinesses'
      @$el.find('.active').removeClass('active')
      @$el.find('.myBusinesses').addClass('active')
      @updatePageTitle("My Businesses")
    if route is 'myEvents'
      @$el.find('.active').removeClass('active')
      @$el.find('.myEvents').addClass('active')
      @updatePageTitle("My Events")
    if route is 'myWidgets'
      @$el.find('.active').removeClass('active')
      @$el.find('.myApps').addClass('active')
      @updatePageTitle("My Apps") 
    if route is 'account' 
      @$el.find('.active').removeClass('active')
      @$el.find('.profileActions').addClass('active')
      @updatePageTitle("My Account") 
    if route is 'media'
      @$el.find('.active').removeClass('active')
      @$el.find('.profileActions').addClass('active')
      @updatePageTitle("My Media Library")
    


  logout:(e)->
    Chaplin.helpers.redirectTo {url: 'logout'}

  redirectToEvents: (e) ->
    Chaplin.helpers.redirectTo {url: 'myEvents'}

  redirectToBusinesses: (e) ->
    Chaplin.helpers.redirectTo {url: 'myBusinesses'} 

  redirectToMedia: (e) ->
    Chaplin.helpers.redirectTo {url: 'media'}

  redirectToApps: (e) ->
    Chaplin.helpers.redirectTo {url: 'myWidgets'}

  redirectToAccount: (e) ->
    Chaplin.helpers.redirectTo {url: 'account'}

  updatePageTitle:(title)=>
    $('.page-title>h2').html(title)

  getCurrentUrl: ()->
    locale = window.location
    return locale.href.replace(window.baseUrl, '')
    
