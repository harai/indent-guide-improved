{CompositeDisposable, Point} = require 'atom'

{createElementsForGuides, styleGuide} = require './indent-guide-improved-element'
{getGuides} = require './guides.coffee'
RowMap = require './row-map.coffee'

module.exports =
  activate: (state) ->
    # The original indent guides interfere with this package.
    atom.config.set('editor.showIndentGuide', false)

    unless atom.config.get('editor.useShadowDOM')
      msg = 'To use indent-guide-improved package, please check "Use Shadow DOM" in Settings.'
      atom.notifications.addError(msg, {dismissable: true})
      return

    updateGuide = (editor, editorElement) ->
      visibleScreenRange = editor.getVisibleRowRange()
      basePixelPos = editorElement.pixelPositionForScreenPosition(new Point(visibleScreenRange[0], 0)).top
      visibleRange = visibleScreenRange.map (row) ->
        editor.bufferPositionForScreenPosition(new Point(row, 0)).row
      getIndent = (row) ->
        if editor.lineTextForBufferRow(row).match(/^\s*$/)
          null
        else
          editor.indentationForBufferRow(row)
      scrollTop = editor.getScrollTop()
      scrollLeft = editor.getScrollLeft()
      rowMap = new RowMap(editor.displayBuffer.rowMap.getRegions())
      guides = getGuides(
        visibleRange[0],
        visibleRange[1],
        editor.getLastBufferRow(),
        editor.getCursorBufferPositions().map((point) -> point.row),
        getIndent)
      lineHeightPixel = editor.getLineHeightInPixels()
      createElementsForGuides(editorElement, guides.map (g) ->
        (el) -> styleGuide(
          el,
          g.point.translate(new Point(visibleRange[0], 0)),
          g.length,
          g.stack,
          g.active,
          editor,
          rowMap,
          basePixelPos,
          lineHeightPixel,
          visibleScreenRange[0],
          scrollTop,
          scrollLeft))

    handleEvents = (editor, editorElement) ->
      subscriptions = new CompositeDisposable
      subscriptions.add editor.onDidChangeCursorPosition(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidChangeScrollTop(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidChangeScrollLeft(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidStopChanging(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidDestroy ->
        subscriptions.dispose()

    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      handleEvents(editor, editorElement)
