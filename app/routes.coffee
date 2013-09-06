module.exports = (match) ->
  match '', 'home#home'

  # Marketing/Pre-Login Routes
  match 'about', 'marketing#about'
  match 'localBusinesses', 'marketing#localBusinesses'
  match 'publishers', 'marketing#publishers'
  match 'signUp', 'registration#registerUser'

  # Post-Login Routes
  match 'myBusinesses', 'business#list'
  match 'business', 'business#create'
  match 'business/:id', 'business#edit'  
  match 'myEvents', 'event#list'
  match 'myEvents/more', 'event#more'
  match 'myEvents/past', 'event#past'
  match 'event', 'event#create'
  match 'event/:id', 'event#edit'  
  match 'myWidgets',  'widget#list'
  match 'widget', 'widget#create'
  match 'widget/:id', 'widget#edit'
  match 'account/change-password', 'account#changePassword' 
  match 'account/forgot-password', 'account#resetPassword'
  match 'password/reset', 'account#newPassword'
  match 'event/:id/promote', 'event#promote'

  # login/logout
  match 'login', 'login#login', name: 'auth_login'
  match 'logout', 'login#logout',name: 'auth_logout'
  match 'login/forgot-password', 'login#resetPassword'

  #demo route
  match 'image', 'home#index'
  match 'media', 'media#index'
