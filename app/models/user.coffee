Model = require 'models/base/model'

module.exports = class User extends Model
  
  url: ->
    if @isNew()
      return "/api/user"
    else
      return "/api/user/#{@id}"

  getToken : (uname, pword) ->
    $.ajax
        type: 'POST',
        contentType: 'application/json',
        url:  '/api/tokenRequest',
        data: JSON.stringify({password : pword,email : uname}),
        success: (body,response, xHr) =>
          $.cookie('token', body.authToken, path: '/')
          $.cookie('user', body.user, path: '/')
          user = new User()
          user.id = body.user
          user.fetch
            success: =>
              @loginSuccess(user)
        error: (body,response, xHr) =>
          errorResponse = JSON.parse(body.responseText)
          $('.errors').append("<span class='error'>#{errorResponse.message}</span>")
          console.log 'could not authenticate'
          
  loginSuccess : (user) =>
    Chaplin.datastore.user = user
    if not Chaplin.mediator.redirectUrl
      @publishEvent '!router:route', 'myEvents'
    else
      @publishEvent '!router:route', Chaplin.mediator.redirectUrl
    @publishEvent 'loginStatus', true
  
  changePassword :(id, password, currentPassword)=>
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
          @getToken user.email, password
        else
          user = new User()
          user.id = id
          user.fetch
            success: =>
              @loginSuccess(user)
            error: (body, response, xHr) =>
              console.log "Error changing password"
      error: (body, response, xHr) =>
        $('.errors').append("<span class='error'>#{JSON.parse(body.responseText).message}</span>")

  resetPassword:(email)=>
    $.ajax
      type:'POST'
      contentType:'application/json'
      url: "/api/passwordReset/emailRequest"
      data: JSON.stringify({email:email})
      success: (body, response, xHr)=>
        console.log body
        console.log response
      error:(body, response, xHr) =>
        $('.errors').append("<span class='error'>Email sent.</span>")

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
        console.log "error case"
        if body.status is 403
          $('.errors').append("<span class='error'>Your email address was not found. Please register or try to log in using a different account.</span>")
        else
          $('.errors').append("<span class='error'>Something went wrong.</span>")

