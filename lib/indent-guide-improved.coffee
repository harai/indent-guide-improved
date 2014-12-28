{CompositeDisposable} = require 'atom'

IndentGuideImprovedElement = require './indent-guide-improved-element'

module.exports = IndentGuideImproved =
  activate: (state) ->
    atom.workspace.observeTextEditors (editor) ->
      editorElement = atom.views.getView(editor)
      indentGuideImprovedElement = new IndentGuideImprovedElement().initialize(editor, editorElement)
      editorElement.querySelector(".underlayer")?.appendChild(indentGuideImprovedElement)
