Collection = require 'models/base/collection'
User = require('models/user')

module.exports = class Users extends Collection
  Model : User
  url: 'http://METkwI15Bg0heuRNaru6:6n0pRhok4WR8yx8VudUD7XshboNCz51oFXJvZA2y@localhost:8080/user'
  
