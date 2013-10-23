View = require 'views/base/view'
template = require 'templates/site'
FooterView = '/views/footer'
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

  listen:
    'showForgotPassword mediator' : 'forgotPassword'
    'showResetPassword mediator' : 'resetPassword'

  forgotPassword: (e) ->
    console.log 'forgot password listener triggered'
    e.preventDefault() if e
    @subview('forgotPasswordModal', new ForgotPassword({container: $('#forgotPasswordModal .modal-content')}))  
    $('#forgotPasswordModal').modal('show')  

  resetPassword: (e) ->
    e.preventDefault() if e
    @subview('resetPasswordModal', new ResetPassword({container: $('#resetPasswordModal .modal-content')}))  
    $('#resetPasswordModal').modal('show')        