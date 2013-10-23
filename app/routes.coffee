module.exports = (match) ->
  match '', 'event#list'

  # login/logout
  match 'register', 'login#register'
  match 'login', 'login#login'
  match 'logout', 'login#logout'
  match 'forgotPassword', 'login#login', params: { showForgotPassword: true }
  match 'password/reset', 'login#login', params: { showResetPassword: true}  

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
  match 'account', 'account#manage'
  match 'event/:id/promote', 'event#promote'

  #404
  match '*anything', 'home#error'