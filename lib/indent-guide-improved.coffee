IndentGuideImprovedView = require './indent-guide-improved-view'
{CompositeDisposable} = require 'atom'

module.exports = IndentGuideImproved =
  indentGuideImprovedView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @indentGuideImprovedView = new IndentGuideImprovedView(state.indentGuideImprovedViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @indentGuideImprovedView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'indent-guide-improved:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @indentGuideImprovedView.destroy()

  serialize: ->
    indentGuideImprovedViewState: @indentGuideImprovedView.serialize()

  toggle: ->
    console.log 'IndentGuideImproved was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
