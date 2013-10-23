View = require 'views/base/view'
template = require 'templates/site'
FooterView = '/views/footer'
LoginPopover = require 'views/loginPopover'
ForgotPassword = require 'views/forgotPassword'
ResetPassword = require 'views/reset-password'

# Site view is a top-level view which is bound to body.
module.exports = class SiteView extends View
  container: 'body'
  id: 'site-container'
  regions:
    topNav: '#topNav'
    header: '#header-container'
    main: '#page-container'
    footer: '#footer'
  template: template

  events:
    'click .sign-in' : 'login'

  listen:
    'showLogin mediator' : 'login'
    'showForgotPassword mediator' : 'forgotPassword'
    'showResetPassword mediator' : 'resetPassword'

  initialize: ->
    super
    console.log 'init'

  login: (e) ->
    console.log 'show login'
    e.preventDefault() if e
    @subview('loginPopover', new LoginPopover({container: $('#loginModal .modal-content')}))  
    $('#loginModal').modal('show')

  forgotPassword: (e) ->
    console.log 'forgot password listener triggered'
    e.preventDefault() if e
    @subview('forgotPasswordModal', new ForgotPassword({container: $('#forgotPasswordModal .modal-content')}))  
    $('#forgotPasswordModal').modal('show')  

  resetPassword: (e) ->
    e.preventDefault() if e
    @subview('resetPasswordModal', new ResetPassword({container: $('#resetPasswordModal .modal-content')}))  
    $('#resetPasswordModal').modal('show')        