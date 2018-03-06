{Point} = require 'atom'

styleGuide = (element, point, length, stack, active, editor, basePixelPos, lineHeightPixel, baseScreenRow) ->
  element.classList.add('indent-guide-improved')
  element.classList[if stack then 'add' else 'remove']('indent-guide-stack')
  element.classList[if active then 'add' else 'remove']('indent-guide-active')

  if editor.isFoldedAtBufferRow(Math.max(point.row - 1, 0))
    element.style.height = '0px'
    return

  row = editor.screenRowForBufferRow(point.row)
  indentSize = editor.getTabLength()
  left = point.column * indentSize * editor.getDefaultCharWidth()
  top = basePixelPos + lineHeightPixel * (row - baseScreenRow)

  element.style.left = "#{left}px"
  element.style.top = "#{top}px"
  element.style.height =
    "#{editor.getLineHeightInPixels() * realLength(point.row, length, editor)}px"
  element.style.display = 'block'
  element.style['z-index'] = 1

realLength = (row, length, editor) ->
  row1 = editor.screenRowForBufferRow(row)
  row2 = editor.screenRowForBufferRow(row + length)
  row2 - row1

IndentGuideImprovedElement = document.registerElement('indent-guide-improved')

createElementsForGuides = (editorElement, fns) ->
  cursors = editorElement.querySelector('.scroll-view .cursors')
  itemParent = cursors.parentNode
  items = itemParent.querySelectorAll('.indent-guide-improved')
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
    newNode.classList.add('overlayer')
    fns[count++](newNode)
    itemParent.insertBefore(newNode, cursors)
  throw 'System Error' unless count is neededNum

module.exports =
  createElementsForGuides: createElementsForGuides
  styleGuide: styleGuide
