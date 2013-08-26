module.exports = (match) ->
  match '', 'event#list'

  # Marketing/Pre-Login Routes

  # Post-Login Routes
  match 'myBusinesses', 'business#list'
  match 'business', 'business#create'
  match 'business/:id', 'business#edit'  
  match 'myEvents', 'event#list'
  match 'event', 'event#create'
  match 'event/:id', 'event#edit'  




  # login/logout
  match 'login', 'login#login', name: 'auth_login'
  match 'logout', 'home#logout',name: 'auth_logout'

  # demo routes for Dev Teams Proof Of Concepts
  match 'demo/promotionTargets', 'demo#promotionTargets'
  match 'demo/register', 'demo#registerUser'
  match 'demo/changePassword', 'demo#changePassword' 
  match 'demo/forgot-password', 'demo#resetPassword'
  match 'password/reset', 'demo#newPassword'
