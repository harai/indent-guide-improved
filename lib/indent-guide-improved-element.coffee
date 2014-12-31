{CompositeDisposable} = require 'atom'

class IndentGuideImprovedElement extends HTMLDivElement
  initialize: (@point, @length, @editor) ->
    @classList.add('indent-guide-improved')
    @updateGuide()
    this

  updateGuide: ->
    startPos = @editor.pixelPositionForBufferPosition(@point)
    @style.left = "#{startPos.left}px"
    @style.top = "#{startPos.top}px"
    @style.height = "#{@editor.getLineHeightInPixels() * @length}px"
    @style.display = 'block'

module.exports = document.registerElement('indent-guide-improved',
  extends: 'div'
  prototype: IndentGuideImprovedElement.prototype
)
