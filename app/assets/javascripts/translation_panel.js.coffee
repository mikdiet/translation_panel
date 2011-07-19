$.translator = translator =
  initialize: ->
    return false unless translationPanel?
    translator.loadData().render()
  loadData: ->
    translator.translatesData = translationPanel.translates || []
    translator.locale = translationPanel.locale
    translator.save_action = translationPanel.action
    translator
  render: ->
    translator.container = $('<div id="translator"></div>').html("Open Translate Panel")
    translator.container.appendTo($('body'))
    translator.renderPanel().renderForm().setHandlers()
  renderPanel: ->
    translator.panel = $('<div id="translator_panel"><ul/></div>').appendTo($('body')).dialog
      autoOpen: false
      dialogClass: 'translator'
      position: ['right',30]
    translator.addTranslates translator.translatesData
    translator
  translates: []
  addTranslates: (translatesData) ->
    translator.addTranslate t for t in translatesData
  addTranslate: (translateData) ->
    if translator.translates[translateData.key]?
      translator.translates[translateData.key].element.remove()
    translator.translates[translateData.key] =
      value: translateData.value
      element: $('<li/>').append($('<a href="#" />').html(translateData.key))
          .append($('<span/>')).appendTo translator.panel.find('ul')
      change_translate: ->
        if this.value? and this.value!=""
          this.element.find('span').text(this.value)
        else
          this.element.find('span').html("<i>no translation</i>")
    translator.translates[translateData.key].change_translate()
  renderForm: ->
    translator.form = $('<form />').attr
      id: 'translator_form'
      "accept-charset": "UTF-8"
      action: translator.save_action
      method: "get"
    $('<span id="translator_key_span" />').appendTo(translator.form)
    $('<input type="hidden" />').appendTo(translator.form).attr
      id: 'translator_key'
      name: 'key'
    $('<input type="text" />').appendTo(translator.form).attr
      id: 'translator_value'
      name: 'value'
    $('<input type="hidden" />').appendTo(translator.form).attr
      name: 'locale'
      value: translator.locale
    $('<input type="submit" />').appendTo(translator.form).attr
      name: 'submit'
      value: 'Update'
    translator.form.appendTo($('body')).dialog
      autoOpen: false
      dialogClass: 'translator'
      position: ['center',30]
      width: 450
    translator
  setHandlers: ->
    translator.container.click -> 
      if translator.panel.dialog('isOpen')
        translator.panel.dialog('close')
      else
        translator.panel.dialog('open')
    translator.panel.find('li a').click ->
      translator.form.dialog('open') unless translator.form.dialog('isOpen')
      $('#translator_key_span').html $(this).html()
      $('#translator_key').val $(this).html()
      $('#translator_value').val translator.translates[$(this).html()].value
      false
    translator.form.submit ->
      request = $.ajax
        url: translator.form.attr('action')
        data: translator.form.serializeArray()
        success: (data, textStatus, jqXHR) -> 
          jqXHR.translate.change_translate()
        error: (jqXHR, status) ->
          jqXHR.translate.element.find('span').html('<i>Error!! ('+status+')</i>')
      request.translate = translator.translates[$('#translator_key').val()]
      request.translate.value = $('#translator_value').val()
      request.translate.element.find('span').html('<i>saving..</i>')
      translator.form.dialog('close')
      false

$ -> $.translator.initialize()
