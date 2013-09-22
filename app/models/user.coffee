Model = require 'models/base/model'

module.exports = class User extends Model
  
  validation :
    firstName:
      required: true
    lastName:
      required: true            
    email:
      required: true
      pattern: "email"
    phone:
      required: false
      pattern: "phone"

  url: ->
    if @isNew()
      return "/api/user"
    else
      return "/api/user/#{@id}"

  getToken : (uname, pword, options) ->
    $.ajax
        type: 'POST',
        contentType: 'application/json',
        url:  '/api/tokenRequest',
        data: JSON.stringify({password : pword,email : uname}),
        success: (body,response, xHr) =>
          console.log 'got token'
          console.log body
          $.cookie('token', body.authToken, path: '/')
          $.cookie('user', body.user, path: '/')
          user = new User()
          user.id = body.user
          user.fetch
            success: =>
              @loginSuccess(user, options)
        error: (body,response, xHr) =>
          if body.responseText
            errorResponse = JSON.parse(body.responseText).message
          else
            errorResponse = "Unable to login.  Please check your username and password."
          options.onError(errorResponse) if options.onError
          
  loginSuccess : (user, options) =>
    Chaplin.datastore.loadEssential
      success: =>
        if options?.onSuccess
          options.onSuccess()
        else
          if Chaplin.datastore.business.hasNone()
            @publishEvent '!router:route', 'myBusinesses'
          else      
            @publishEvent '!router:route', 'myEvents'
    @publishEvent 'loginStatus', true
  
  changePassword :(id, password, currentPassword, options)=>
    $.ajax
      type: 'PUT'
      contentType:'application/json'
      url: "/api/user/#{id}/password"
      data: JSON.stringify({password:password, currentPassword: currentPassword, id: id})
      success: (body, response, xHr) =>
        id = $.cookie('user')
        $.removeCookie('token')
        $.removeCookie('user')
        user = Chaplin.datastore.user
        if user
          @getToken user.get('email'), password, options
        else
          user = new User()
          user.id = id
          user.fetch
            success: =>
              @loginSuccess(user, options)
      error: (body, response, xHr) =>
        if options.onError
          options.onError()
        else
          $('.errors').empty().html("<span class='error'>#{JSON.parse(body.responseText).message}</span>")

  resetPassword:(email)=>
    $.ajax
      type:'POST'
      contentType:'application/json'
      url: "/api/passwordReset/emailRequest"
      data: JSON.stringify({email:email})

  newPassword:(email,newPassword, token)=>
    $.ajax
      type:'POST'
      contentType:'application/json'
      url: "/api/passwordReset"
      data: JSON.stringify({email:email, password:newPassword, token:token})
      success: (body, response, xHr)=>
        $.removeCookie('token')
        $.removeCookie('user')
        window.location = "/login"
      error:(body, response, xHr) =>
        if body.status is 403
          $('.errors').empty().html("<span class='error'>Your email address was not found. Please register or try to log in using a different account.</span>")
        else
          $('.errors').empty().html("<span class='error'>Something went wrong.</span>")

