module.exports = (match) ->
  match '', 'home#index'
  match 'users', 'users#index'
  match 'dashboard', 'business#list'


  # login/logout
  match 'login', 'login#login', name: 'auth_login'
  match 'logout', 'login#logout',name: 'auth_logout'


  # demo routes for Dev Teams Proof Of Concepts
  match 'demo/promotionTargets', 'demo#promotionTargets'