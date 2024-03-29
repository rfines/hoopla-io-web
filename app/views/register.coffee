template = require 'templates/register'
View = require 'views/base/view'
User = require 'models/user'

module.exports = class Register extends View
  template: template
  autoRender: false

  events:
    'click .btn.signUp' : 'register'

  initialize: ->
    super
    if window.user and window.authToken and window.userEmail
      $.cookie('token', window.authToken, path: '/')
      $.cookie('user', window.user, path: '/')
      mixpanel.identify(window.userEmail);
      mixpanel.people.set({
        "$email": window.userEmail
        "$last_login": new Date().toISOString()
      });
      @publishEvent 'trackEvent', 'Register'
      window.location = '/'
    else
      @model = new User()
      @render()

  attach: ->
    super
    params = QueryStringToHash(window.location.search.replace('?', ''))
    if params?.email
      @$el.find('.username').val(params.email)
    if params?.message
      if params.message is 'Validation failed'
        @showError "All fields are required", ['email', 'password', 'password-confirm']
      else
        @showError {message: params.message}

  register: (e) ->
    e.preventDefault()
    @clearErrors()
    uname = @$el.find('.username:visible').val()
    pword = @$el.find('.password:visible').val()
    pwordconfirm = @$el.find('.password-confirm:visible').val()
    if uname and pword and pwordconfirm
      if pword != pwordconfirm
        @showError "Passwords do not match.", ['password', 'password-confirm']
      else
        if $.cookie('token')
          $.removeCookie('token')
          $.removeCookie('user')
        @model.set
          email: uname
          password: pword
        @model.save  {}, {
          success: (model, response, options)=> 
            mixpanel.identify(uname);
            mixpanel.people.set({
              "$email": uname
              "$last_login": new Date().toISOString()
            });
            @publishEvent 'trackEvent', 'Register'          
            model.getToken uname, pword    
          error: (err, xhr, options) =>
            if xhr.responseJSON?.message is 'Validation failed'
              @showError 'A valid email address is required.'
            else
              @showError xhr.responseJSON
        }
    else
      @showError "All fields are required", ['email', 'password', 'password-confirm']

  showError: (msg, fields) =>   
    @$el.find('.alert').show()
    if _.isObject(msg) and msg.message.indexOf('duplicate') > -1
      @$el.find('.message').text("#{@$el.find('.username').val()} is already used on hoopla.io.");
    else
      @$el.find('.message').text(msg)    
    if fields
      for x in fields
        @$el.find("input[name='#{x}']").parent().addClass('has-error')
  
  clearErrors: () ->
    @$el.find('.has-error').removeClass('has-error')

  QueryStringToHash : QueryStringToHash = (query) ->
    query_string = {}
    vars = query.split("&")
    i = 0

    while i < vars.length
      pair = vars[i].split("=")
      pair[0] = decodeURIComponent(pair[0])
      pair[1] = decodeURIComponent(pair[1])
      
      # If first entry with this name
      if typeof query_string[pair[0]] is "undefined"
        query_string[pair[0]] = pair[1]
      
      # If second entry with this name
      else if typeof query_string[pair[0]] is "string"
        arr = [query_string[pair[0]], pair[1]]
        query_string[pair[0]] = arr
      
      # If third or later entry with this name
      else
        query_string[pair[0]].push pair[1]
      i++
    query_string    