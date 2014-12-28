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
    column = 5
    columnWidth = @editorElement.getDefaultCharacterWidth() * column
    topPos = 100
    bottomPos = 200
    @style.left = "#{columnWidth}px"
    @style.top = "#{topPos}px"
    @style.bottom = "#{bottomPos}px"
    @style.display = 'block'

module.exports = document.registerElement('indent-guide-improved',
  extends: 'div'
  prototype: IndentGuideImprovedElement.prototype
)
