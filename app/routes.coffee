module.exports = (match) ->
  match '', 'home#home'

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
  match 'password/reset', 'account#newPassword'

  # login/logout
  match 'login', 'login#login', name: 'auth_login'
  match 'logout', 'home#logout',name: 'auth_logout'
  match 'login/forgot-password', 'login#resetPassword'

  #demo route
  match 'image', 'home#index'
  match 'media', 'media#index'
