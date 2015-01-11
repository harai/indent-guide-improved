{CompositeDisposable, Point} = require 'atom'

IndentGuideImprovedElement = require './indent-guide-improved-element'
{toGuides} = require './guides.coffee'

module.exports =
  activate: (state) ->
    updateGuide = (editor, editorElement) ->
      underlayer = editorElement.querySelector(".underlayer")
      if !underlayer?
        return
      visibleRange = editor.getVisibleRowRange().map (row) ->
        editor.bufferPositionForScreenPosition(new Point(row, 0)).row
      cursorRows = editor.getCursorBufferPositions().map (point) ->
        point.row - visibleRange[0]
      items = underlayer.querySelectorAll('.indent-guide-improved')
      Array.prototype.forEach.call items, (node) ->
        node.parentNode.removeChild(node)
      indents = [visibleRange[0]..Math.min(visibleRange[1], editor.getLastBufferRow())].map (n) ->
        if editor.lineTextForBufferRow(n).match(/^\s*$/)
          null
        else
          editor.indentationForBufferRow(n)
      toGuides(indents, cursorRows).forEach (g) ->
        underlayer.appendChild(
          new IndentGuideImprovedElement().initialize(
            g.point.translate(new Point(visibleRange[0], 0)),
            g.length,
            g.stack,
            g.active,
            editor.getTabLength(),
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
