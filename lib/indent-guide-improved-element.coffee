{CompositeDisposable} = require 'atom'

class IndentGuideImprovedElement extends HTMLDivElement
  initialize: (@editor, @editorElement) ->
    @classList.add('indent-guide-improved')
    @handleEvents()
    @updateGuide()
    this

  handleEvents: ->
    updateGuideCallback = => @updateGuide()

    subscriptions = new CompositeDisposable
    subscriptions.add @editor.onDidChangeCursorPosition(updateGuideCallback)

    subscriptions.add @editor.onDidDestroy ->
      subscriptions.dispose()

  updateGuide: ->
    column = @getGuideColumn(@editor.getPath(), @editor.getGrammar().scopeName)
    columnWidth = @editorElement.getDefaultCharacterWidth() * column
    @style.left = "#{columnWidth}px"
    @style.display = 'block'

module.exports = document.registerElement('indent-guide-improved',
  extends: 'div'
  prototype: IndentGuideImprovedElement.prototype
)
