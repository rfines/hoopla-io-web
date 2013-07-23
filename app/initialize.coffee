Application = require 'application'
routes = require 'routes'

$ ->
  new Application {
    title: 'Brunch example application',
    controllerSuffix: '-controller',
    routes
  }
