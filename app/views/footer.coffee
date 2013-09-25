View = require 'views/base/view'
template = require 'templates/footer'

module.exports = class Footer extends View
  className: 'row'
  region: 'footer'
  template: template