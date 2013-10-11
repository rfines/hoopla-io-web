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
    if not route
      parts = location.href.split('/')
      route = parts[parts.length - 1]
    if route is 'myBusinesses'
      @$el.find('.active').removeClass('active')
      @$el.find('.myBusinesses').addClass('active')
      @updatePageTitle("My Businesses")
    else if route is 'myEvents'
      @$el.find('.active').removeClass('active')
      @$el.find('.myEvents').addClass('active')
      @updatePageTitle("My Events")
    else if route is 'myWidgets'
      @$el.find('.active').removeClass('active')
      @$el.find('.myApps').addClass('active')
      @updatePageTitle("My Apps") 
    else if route is 'account' 
      @$el.find('.active').removeClass('active')
      @$el.find('.profileActions').addClass('active')
      @updatePageTitle("My Account") 
    else if route is 'media' and location.href.split('/').indexOf('myEvents') is -1 and location.href.split('/').indexOf('myBusinesses') is -1
      @$el.find('.active').removeClass('active')
      @$el.find('.profileActions').addClass('active')
      @updatePageTitle("My Media Library")
    else if route.indexOf('promote') >= 0 and location.href.split('/').indexOf('myEvents') is -1 and location.href.split('/').indexOf('myBusinesses') is -1
      @updatePageTitle("Promote Event")

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
    
  $(document).on "click", ".navbar-collapse.in", (e) ->
    $(this).removeClass("in").addClass "collapse"  if $(e.target).is("a")
    
