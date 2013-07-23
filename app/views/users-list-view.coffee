template = require 'views/templates/users/list'
CollectionView = require 'views/base/collection-view'
UserView = require 'views/user-view'

module.exports = class UsersListView extends CollectionView
  autoRender: true
  renderItems: true
  className: 'users-list'
  template: template
  itemView: UserView

  initialize: ->
    console.log 'collection'
    console.log @collection
    super