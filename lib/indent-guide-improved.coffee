{CompositeDisposable, Point} = require 'atom'

{createElementsForGuides, styleGuide} = require './indent-guide-improved-element'
{getGuides} = require './guides.coffee'
RowMap = require './row-map.coffee'

module.exports =
  activate: (state) ->
    # The original indent guides interfere with this package.
    atom.config.set('editor.showIndentGuide', false);

    updateGuide = (editor, editorElement) ->
      underlayer = editorElement.querySelector(".underlayer")
      if !underlayer?
        return

      visibleScreenRange = editor.getVisibleRowRange()
      basePixelPos = editorElement.pixelPositionForScreenPosition(new Point(visibleScreenRange[0], 0)).top
      visibleRange = visibleScreenRange.map (row) ->
        editor.bufferPositionForScreenPosition(new Point(row, 0)).row
      getIndent = (row) ->
        if editor.lineTextForBufferRow(row).match(/^\s*$/)
          null
        else
          editor.indentationForBufferRow(row)
      rowMap = new RowMap(editor.displayBuffer.rowMap.getRegions())
      guides = getGuides(
        visibleRange[0],
        visibleRange[1],
        editor.getLastBufferRow(),
        editor.getCursorBufferPositions().map((point) -> point.row),
        getIndent)
      lineHeightPixel = editor.getLineHeightInPixels()
      createElementsForGuides(underlayer, guides.map (g) ->
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
          visibleScreenRange[0]))

    handleEvents = (editor, editorElement) ->
      subscriptions = new CompositeDisposable
      subscriptions.add editor.onDidChangeCursorPosition(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidChangeScrollTop(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidStopChanging(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidDestroy ->
        subscriptions.dispose()

    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      if editorElement.querySelector(".underlayer")?
        handleEvents(editor, editorElement)
