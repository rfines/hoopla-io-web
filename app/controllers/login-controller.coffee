module.exports = class LoginController extends Chaplin.Controller

  logout: ->
    $.removeCookie('token')
    $.removeCookie('user')
    delete Chaplin.datastore.user
    window.location = "/"