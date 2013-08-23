module.exports = (match) ->
  match '', 'business#list'

  # Marketing/Pre-Login Routes
  match 'about', 'marketing#about'
  match 'signUp', 'registration#registerUser'

  # Post-Login Routes
  match 'myBusinesses', 'business#list'
  match 'business', 'business#create'
  match 'business/:id', 'business#edit'  
  match 'myEvents', 'event#list'
  match 'event', 'event#create'
  match 'event/:id', 'event#edit'  
  match 'account/change-password', 'account#changePassword' 
  match 'account/forgot-password', 'account#resetPassword'
  match 'password/reset', 'demo#newPassword'



  # login/logout
  match 'login', 'login#login', name: 'auth_login'
  match 'logout', 'home#logout',name: 'auth_logout'

  # demo routes for Dev Teams Proof Of Concepts
  match 'demo/register', 'demo#registerUser'
  match 'demo/changePassword', 'demo#changePassword'
  match 'demo/myBusinesses', 'demo#businessDashboard'
  match 'demo/event/list', 'demo#eventDashboard'
  match 'demo/myEvents', 'demo#eventDashboard'
  match 'demo/business/list', 'demo#businessDashboard'
  match 'demo/business/events', 'demo#businessEvents'
  match 'image', 'home#index'