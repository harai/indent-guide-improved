{CompositeDisposable, Point} = require 'atom'
_ = require 'lodash'

{createElementsForGuides, styleGuide} = require './indent-guide-improved-element'
{getGuides} = require './guides.coffee'
RowMap = require './row-map.coffee'

module.exports =
  activate: (state) ->
    @currentSubscriptions = []

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


    handleEvents = (editor, editorElement) =>
      up = () ->
        updateGuide(editor, editorElement)

      update = _.throttle(up , 30)

      subscriptions = new CompositeDisposable
      subscriptions.add editor.onDidChangeCursorPosition(update)
      subscriptions.add editor.onDidChangeScrollTop(update)
      subscriptions.add editor.onDidChangeScrollLeft(update)
      subscriptions.add editor.onDidStopChanging(update)
      subscriptions.add editor.onDidDestroy =>
        @currentSubscriptions.splice(@currentSubscriptions.indexOf(subscriptions), 1)
        subscriptions.dispose()
      @currentSubscriptions.push(subscriptions)

    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      handleEvents(editor, editorElement)

  deactivate: () ->
    @currentSubscriptions.forEach (s) ->
      s.dispose()
    atom.workspace.getTextEditors().forEach (te) ->
      v = atom.views.getView(te)
      return unless v
      Array.prototype.forEach.call(v.querySelectorAll('.indent-guide-improved'), (e) ->
        e.parentNode.removeChild(e)
      )
