Collection = require 'models/base/collection'
User = require('models/user')

module.exports = class Users extends Collection
  Model : User
  url: "#{window.apiUrl}user"
  
