{Point} = require 'atom'

toG = (indents, begin, depth, cursorRows) ->
  ptr = begin
  isActive = false
  isStack = false

  gs = []
  while ptr < indents.length && depth <= indents[ptr]
    if depth < indents[ptr]
      r = toG(indents, ptr, depth + 1, cursorRows)
      if r.guides[0]?.stack
        isStack = true
      Array.prototype.push.apply(gs, r.guides)
      ptr = r.ptr
    else
      if ptr in cursorRows
        isActive = true
        isStack = true
      ptr++
  gs.unshift
    length: ptr - begin
    point: new Point(begin, depth)
    active: isActive
    stack: isStack
  guides: gs
  ptr: ptr

toGuides = (indents, cursorRows = []) ->
  toG(indents, 0, 0, cursorRows).guides.slice(1).map (g) ->
    length: g.length
    point: g.point.translate(new Point(0, -1))
    active: g.active
    stack: g.stack

module.exports =
  toGuides: toGuides
