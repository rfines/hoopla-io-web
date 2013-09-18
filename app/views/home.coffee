template = require 'templates/home'
View = require 'views/base/view'
User = require 'models/user'

module.exports = class HomePageView extends View
  autoRender: true
  className: 'home-page'
  template: template

  initialize: (options) ->
    console.log options
    super()
    @showLogin = options.showLogin
    @showForgotPassword = options.showForgotPassword

  events:
    'click .registerForm .btn' : 'register'

  attach: ->
    super()
    $("#topnav").localScroll 3000
    $(".gobtnwrapper").localScroll 3000
    $(".well").parallax "50%", 0.1
    $(".navbar .nav > li > a").click ->
      $(".navbar-collapse.navbar-ex1-collapse.in").removeClass("in").addClass("collapse").css "height", "0"
    @publishEvent 'showLogin' if @showLogin
    @publishEvent 'showForgotPassword' if @showForgotPassword

  register: (e) ->
    e.preventDefault()
    @model = new User();
    uname = @$el.find('.registerForm input[name=email]').val()
    pword = @$el.find('.registerForm input[name=password]').val()
    if uname and pword
        if $.cookie('token')
          $.removeCookie('token')
          $.removeCookie('user')
        @model.set
          email: uname
          password: pword
        @model.save  {}, {
          success: (model, response, options)-> 
            model.getToken uname, pword    
          error: (err, xhr, options) => 
            alert('Failed to create your account')
        }
    else
      alert('Email and Password are required')