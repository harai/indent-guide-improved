{CompositeDisposable, Point} = require 'atom'

{createElementsForGuides, styleGuide} = require './indent-guide-improved-element'
{getGuides} = require './guides.coffee'

module.exports =
  activate: (state) ->
    @currentSubscriptions = []

    # The original indent guides interfere with this package.
    atom.config.set('editor.showIndentGuide', false)

    updateGuide = (editor, editorElement) ->
      visibleScreenRange = editorElement.getVisibleRowRange()
      return unless visibleScreenRange? and editorElement.component?
      basePixelPos = editorElement.pixelPositionForScreenPosition(new Point(visibleScreenRange[0], 0)).top
      visibleRange = visibleScreenRange.map (row) ->
        editor.bufferPositionForScreenPosition(new Point(row, 0)).row
      getIndent = (row) ->
        if editor.lineTextForBufferRow(row).match(/^\s*$/)
          null
        else
          editor.indentationForBufferRow(row)
      scrollTop = editorElement.getScrollTop()
      scrollLeft = editorElement.getScrollLeft()
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
          basePixelPos,
          lineHeightPixel,
          visibleScreenRange[0],
          scrollTop,
          scrollLeft))


    handleEvents = (editor, editorElement) =>
      up = () ->
        updateGuide(editor, editorElement)

      delayedUpdate = ->
        requestAnimationFrame(up)

      subscriptions = new CompositeDisposable
      subscriptions.add atom.workspace.onDidStopChangingActivePaneItem((item) ->
        delayedUpdate() if item == editor
      )
      subscriptions.add atom.config.onDidChange('editor.fontSize', delayedUpdate)
      subscriptions.add atom.config.onDidChange('editor.fontFamily', delayedUpdate)
      subscriptions.add atom.config.onDidChange('editor.lineHeight', delayedUpdate)
      subscriptions.add editor.onDidChangeCursorPosition(delayedUpdate)
      subscriptions.add editorElement.onDidChangeScrollTop(delayedUpdate)
      subscriptions.add editorElement.onDidChangeScrollLeft(delayedUpdate)
      subscriptions.add editor.onDidStopChanging(delayedUpdate)
      subscriptions.add editor.onDidDestroy =>
        @currentSubscriptions.splice(@currentSubscriptions.indexOf(subscriptions), 1)
        subscriptions.dispose()
      @currentSubscriptions.push(subscriptions)

    atom.workspace.observeTextEditors (editor) ->
      return unless editor?
      editorElement = atom.views.getView(editor)
      return unless editorElement?
      handleEvents(editor, editorElement)
      updateGuide(editor, editorElement)

  deactivate: () ->
    @currentSubscriptions.forEach (s) ->
      s.dispose()
    atom.workspace.getTextEditors().forEach (te) ->
      v = atom.views.getView(te)
      return unless v
      Array.prototype.forEach.call(v.querySelectorAll('.indent-guide-improved'), (e) ->
        e.parentNode.removeChild(e)
      )
