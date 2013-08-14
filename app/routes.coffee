module.exports = (match) ->
  match '', 'home#index'
  match 'users', 'users#index'
  match 'dashboard', 'business#list'
  match 'login', 'home#login'
  # login/logout
  match 'login', 'login#login', name: 'auth_login'
  match 'logout', 'login#logout',name: 'auth_logout'