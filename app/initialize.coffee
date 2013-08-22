Application = require 'application'
routes = require 'routes'
Datastore = require 'datastore'

$ ->
  Chaplin.datastore = new Datastore()
  new Application {
    title: 'Hoopla.io',
    controllerSuffix: '-controller',
    routes
  }
  