View = require 'views/base/view'
template = require 'templates/site'

# Site view is a top-level view which is bound to body.
module.exports = class SiteView extends View
  container: 'body'
  id: 'site-container'
  regions:
    topNav: '#topNav'
    header: '#header-container'
    main: '#page-container'
    footer: '#footer'
  template: template
