{CompositeDisposable, Point} = require 'atom'

class IndentGuideImprovedElement extends HTMLDivElement
  initialize: (@point, @length, @stack, @active, @indentSize, @editor) ->
    @classList.add('indent-guide-improved')
    @classList.add('indent-guide-stack') if @stack
    @classList.add('indent-guide-active') if @active
    @updateGuide()
    this

  updateGuide: ->
    startPos = @editor.pixelPositionForBufferPosition(
      new Point(@point.row, @point.column * @indentSize))
    @style.left = "#{startPos.left}px"
    @style.top = "#{startPos.top}px"
    @style.height = "#{@editor.getLineHeightInPixels() * @realLength()}px"
    @style.display = 'block'

  realLength: ->
    p1 = @editor.screenPositionForBufferPosition(
      new Point(@point.row, 0))
    p2 = @editor.screenPositionForBufferPosition(
      new Point(@point.row + @length, 0))
    p2.row - p1.row


module.exports = document.registerElement('indent-guide-improved',
  extends: 'div'
  prototype: IndentGuideImprovedElement.prototype
)
