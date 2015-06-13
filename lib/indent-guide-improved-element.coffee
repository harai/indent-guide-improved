{Point} = require 'atom'

styleGuide = (element, point, length, stack, active, editor, rowMap, basePixelPos, lineHeightPixel, baseScreenRow, scrollTop, scrollLeft) ->
  element.classList.add('indent-guide-improved')
  element.classList[if stack then 'add' else 'remove']('indent-guide-stack')
  element.classList[if active then 'add' else 'remove']('indent-guide-active')

  return if editor.isFoldedAtBufferRow(Math.max(point.row - 1, 0))
  row = rowMap.firstScreenRowForBufferRow(point.row)
  indentSize = editor.getTabLength()
  left = point.column * indentSize * editor.getDefaultCharWidth() - scrollLeft
  top = basePixelPos + lineHeightPixel * (row - baseScreenRow) - scrollTop

  element.style.left = "#{left}px"
  element.style.top = "#{top}px"
  element.style.height =
    "#{editor.getLineHeightInPixels() * realLength(point.row, length, rowMap)}px"
  element.style.display = 'block'

realLength = (row, length, rowMap) ->
  row1 = rowMap.firstScreenRowForBufferRow(row)
  row2 = rowMap.firstScreenRowForBufferRow(row + length)
  row2 - row1

IndentGuideImprovedElement = document.registerElement('indent-guide-improved')

createElementsForGuides = (editorElement, fns) ->
  items = editorElement.querySelectorAll('.indent-guide-improved')
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
    editorElement.appendChild(newNode)
  throw 'System Error' unless count is neededNum

module.exports =
  createElementsForGuides: createElementsForGuides
  styleGuide: styleGuide
