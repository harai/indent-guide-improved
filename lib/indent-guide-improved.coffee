{CompositeDisposable, Point} = require 'atom'

{createElementsForGuides, styleGuide} = require './indent-guide-improved-element'
{getGuides} = require './guides.coffee'

module.exports =
  activate: (state) ->
    updateGuide = (editor, editorElement) ->
      underlayer = editorElement.querySelector(".underlayer")
      if !underlayer?
        return
      visibleRange = editor.getVisibleRowRange().map (row) ->
        editor.bufferPositionForScreenPosition(new Point(row, 0)).row
      getIndent = (row) ->
        if editor.lineTextForBufferRow(row).match(/^\s*$/)
          null
        else
          editor.indentationForBufferRow(row)
      guides = getGuides(
        visibleRange[0],
        visibleRange[1],
        editor.getLastBufferRow(),
        editor.getCursorBufferPositions().map((point) -> point.row),
        getIndent)
      createElementsForGuides(underlayer, guides.map (g) ->
        (el) -> styleGuide(
          el,
          g.point.translate(new Point(visibleRange[0], 0)),
          g.length,
          g.stack,
          g.active,
          editor))

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
