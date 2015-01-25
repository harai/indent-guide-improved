{Point} = require 'atom'

styleGuide = (element, point, length, stack, active, editor) ->
  element.classList.add('indent-guide-improved')
  element.classList[if stack then 'add' else 'remove']('indent-guide-stack')
  element.classList[if active then 'add' else 'remove']('indent-guide-active')

  return if editor.isFoldedAtBufferRow(Math.max(point.row - 1, 0))
  p = editor.screenPositionForBufferPosition(new Point(point.row, 0))
  indentSize = editor.getTabLength()
  left = point.column * indentSize * editor.getDefaultCharWidth()
  top = editor.pixelPositionForScreenPosition(new Point(p.row, 0)).top

  element.style.left = "#{left}px"
  element.style.top = "#{top}px"
  element.style.height =
    "#{editor.getLineHeightInPixels() * realLength(editor, point, length)}px"
  element.style.display = 'block'

realLength = (editor, point, length) ->
  p1 = editor.screenPositionForBufferPosition(new Point(point.row, 0))
  p2 = editor.screenPositionForBufferPosition(new Point(point.row + length, 0))
  p2.row - p1.row

IndentGuideImprovedElement = document.registerElement('indent-guide-improved')

createElementsForGuides = (underlayer, fns) ->
  items = underlayer.querySelectorAll('.indent-guide-improved')
  existNum = items.length
  neededNum = fns.length
  createNum = Math.max(neededNum - existNum, 0)
  recycleNum = Math.min(neededNum, existNum)
  count = 0
  [0...existNum].forEach (i) ->
    node = items.item(i)
    if i < recycleNum
      fns[count++](node)
    else
      node.parentNode.removeChild(node)
  [0...createNum].forEach (i) ->
    newNode = new IndentGuideImprovedElement()
    fns[count++](newNode)
    underlayer.appendChild(newNode)
  throw 'System Error' unless count is neededNum

module.exports =
  createElementsForGuides: createElementsForGuides
  styleGuide: styleGuide
