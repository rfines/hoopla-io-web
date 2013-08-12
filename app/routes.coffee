module.exports = (match) ->
  match '', 'home#index'
  match 'users', 'users#index'
  match 'dashboard', 'business#list'
