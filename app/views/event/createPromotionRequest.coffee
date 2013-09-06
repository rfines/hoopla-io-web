View = require 'views/base/view'
PromotionRequest = require 'models/promotionRequest'

module.exports = class CreatePromotionReqeust extends View
  template: require 'templates/event/createPromotionRequest'
  autoRender: true
  className: 'create-promotion-requests'

  attach : ->
    super
    @showFacebook()
    @initDatePickers()
    @initTimePickers()
    console.log @data
    business = Chaplin.datastore.business.get(@data.business)
  
  getTemplateData: ->
    td = super()
    td.facebookProfileImageUrl = 
    td
  
  initialize: ->
    super
  events: 
    "submit form.promoRequestFormFacebook": "saveFacebook"
    "submit form.promoRequestFormTwitter" : "saveTwitter"
    "click .facebookTab":"showFacebook"
    "click .twitterTab":"showTwitter"

  initDatePickers: =>
    startDate = new Pikaday
      field: @$el.find('.promoDate')[0]
    if not @model.isNew()
      startDate.setMoment @model.date
      $('.promoDate').val(@model.date.format('YYYY-MM-DD'))

  initTimePickers: =>
    @$el.find('.timepicker').timepicker
      scrollDefaultTime : "12:00"
      step : 15
    if not @model.isNew()
      @$el.find('.startTime').timepicker('setTime', @model.getStartDate().toDate());
      @$el.find('.endTime').timepicker('setTime', @model.getEndDate().toDate());

  saveFacebook:(e) ->
    e.preventDefault()
    console.log "Hi"

  saveTwitter: (e)->
    e.preventDefault()
    console.log "Hi"

  showFacebook: (e)=>
    if e
      e.preventDefault()
    $('.twitterTab').removeClass('active')
    $('.facebookTab').addClass('active')
    $('#facebookPanel').show()
    $('#twitterPanel').hide()

  showTwitter: (e)=>
    e.preventDefault()
    $('.facebookTab').removeClass('active')
    $('.twitterTab').addClass('active')
    $('#twitterPanel').show()
    $('#facebookPanel').hide() 