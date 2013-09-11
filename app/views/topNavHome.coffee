View = require 'views/base/view'
template = require 'templates/topNavHome'
LoginPopover = require 'views/loginPopover'

module.exports = class TopNav extends View
  autoRender: true
  className: 'topNav'
  region: 'topNav'
  template: template

  events:
    'click .loginPopover .cancel' : 'cancel'

  attach: ->
    super()
    @$el.find('.signInButton').popover({placement: 'bottom', content : "<div class='loginPopover'>Hello</div>", html: true}).popover('show').popover('hide')
    @$el.find('.signInButton').on 'shown.bs.popover', =>
      @$el.find('.popover-content').html("<div class='loginPopover'></div>")
      if @subview('loginPopover')
        @removeSubview('loginPopover')
      @subview('loginPopover', new LoginPopover({container: @$el.find('.loginPopover')}))
    

  getTemplateData: ->
    td = super
    td.showLogin = not Chaplin.datastore?.user?
    td

  cancel: ->
    @$el.find('.signInButton').popover('hide')
    @removeSubview('loginPopover')