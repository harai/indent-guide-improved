{CompositeDisposable} = require 'atom'

module.exports = IndentGuideImproved =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @editor = atom.workspace.getActiveEditor()

    @subscriptions.add @editor.onDidChangeCursorPosition(=> @updateIndentGuide())

  deactivate: ->
    @subscriptions.dispose()

  updateIndentGuide: ->
    if @editor?
      # @createMarker([3, 10], @editor)
    console.debug("hoge")

  createMarker: (range, editor) ->
    console.debug("hoge 3")
    markerAttributes =
      class: 'hogehoge'
      invalidate: 'never'
      replicate: false
      persistent: false
      isCurrent: false
    marker = editor.markBufferPosition(range, markerAttributes)
    editor.decorateMarker(marker, type: 'highlight', class: 'hogehoge')
