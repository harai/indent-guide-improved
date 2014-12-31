{CompositeDisposable, Point} = require 'atom'

IndentGuideImprovedElement = require './indent-guide-improved-element'

module.exports =
  activate: (state) ->
    updateGuide = (editor, editorElement) ->
      underlayer = editorElement.querySelector(".underlayer")
      if !underlayer?
        return
      cursor = editor.getCursorBufferPosition()
      items = underlayer.querySelectorAll('.indent-guide-improved')
      Array.prototype.forEach.call items, (node) ->
        node.parentNode.removeChild(node)
      visibleRange = editor.getVisibleRowRange()
      indents = [visibleRange[0]..Math.min(visibleRange[1], editor.getLastBufferRow())].map (n) ->
        editor.indentationForBufferRow(n)
      console.debug indents
      underlayer.appendChild(
        new IndentGuideImprovedElement().initialize(cursor, 4, editor))

    handleEvents = (editorElement, editor) ->
      subscriptions = new CompositeDisposable
      subscriptions.add editor.onDidChangeCursorPosition(=> updateGuide(editor, editorElement))
      subscriptions.add editor.onDidDestroy ->
        subscriptions.dispose()

    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      if editorElement.querySelector(".underlayer")?
        handleEvents(editorElement, editor)
