{CompositeDisposable} = require 'atom'

module.exports = IndentGuideImproved =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    editor = atom.workspace.getActiveEditor()

    @subscriptions.add editor.onDidChangeCursorPosition(=> @updateIndentGuide())

  deactivate: ->
    @subscriptions.dispose()

  updateIndentGuide: ->
    editor = atom.workspace.getActiveEditor()
    console.debug("hoge")
