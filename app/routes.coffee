module.exports = (match) ->
  match '', 'home#index'
  match 'users', 'users#index'
  match 'dashboard', 'business#list'

  # login/logout
  match 'login', 'login#login', name: 'auth_login'
  match 'logout', 'home#logout',name: 'auth_logout'

  # demo routes for Dev Teams Proof Of Concepts
  match 'demo/promotionTargets', 'demo#promotionTargets'
  match 'demo/business', 'demo#createBusiness'
  match 'demo/register', 'demo#registerUser'
  match 'demo/changePassword', 'demo#changePassword'
  match 'demo/business/list', 'demo#businessDashboard'
  match 'demo/business/events', 'demo#businessEvents'