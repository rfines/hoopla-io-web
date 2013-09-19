module.exports = (match) ->
  match '', 'home#home'
  match 'home', 'home#home'

  # Marketing/Pre-Login Routes
  match 'signUp', 'home#home', params: {signup : true}

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
  match 'password/reset', 'home#home', params: { showResetPassword: true}
  match 'event/:id/promote', 'event#promote'


  # login/logout
  match 'login', 'home#home', params: { showLogin: true }
  match 'logout', 'login#logout'
  match 'forgotPassword', 'home#home', params: { showForgotPassword: true }

  #demo route
  match 'image', 'home#index'
  match 'media', 'media#index'
