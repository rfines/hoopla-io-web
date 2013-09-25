template = require 'templates/home'
View = require 'views/base/view'
User = require 'models/user'
Register = require 'views/user-register-view'

module.exports = class HomePageView extends View
  className: 'home-page'
  template: template
  scrollSpeed: 1000

  initialize: (@options) ->
    super(options)
  events:
    'click .registerForm .btn' : 'register'

  attach: ->
    super()
    @subview('signupForm', new Register({container: @$el.find('.signUpArea')}))
    @setupParallax()
    $("html").niceScroll();
    if @options.goto
      setTimeout =>
        console.log @options.goto
        $.scrollTo($("##{@options.goto}"), @scrollSpeed)
      , 1500
    @publishEvent 'showLogin' if @options.showLogin
    @publishEvent 'showForgotPassword' if @options.showForgotPassword
    @publishEvent 'showResetPassword' if @options.showResetPassword
    @delegate 'click', 'a.toBusinesses', =>
      $.scrollTo($("#Businesses"), @scrollSpeed)
    @delegate 'click', 'a.toPublishers', =>
      $.scrollTo($("#Publishers"), @scrollSpeed)    
    @delegate 'click', 'a.toSignUp', =>
      $.scrollTo($("#Contact"), @scrollSpeed)    


  setupParallax: ->
    $(".well").parallax "50%", 0.1
    $(".navbar .nav > li > a").click ->
      $(".navbar-collapse.navbar-ex1-collapse.in").removeClass("in").addClass("collapse").css "height", "0"

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