Collection = require 'models/base/collection'
User = require('models/user')

module.exports = class Users extends Collection
  model : User
  url: "#{window.apiUrl}user"
  
