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
          console.log 'could not authenticate'
          

  loginSuccess : (user) =>
    Chaplin.datastore.user = user
    if not Chaplin.mediator.redirectUrl
      @publishEvent '!router:route', 'dashboard'
    else
      @publishEvent '!router:route', Chaplin.mediator.redirectUrl
    @publishEvent 'loginStatus', true
  
  changePassword :(id, password, currentPassword)=>
    console.log "Changing password"
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
        console.log body
        console.log response
        console.log xHr
        console.log "error changing password"

