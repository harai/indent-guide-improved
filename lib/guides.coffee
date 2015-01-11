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

fillInNulls = (indents) ->
  res = indents.reduceRight(
    (acc, cur) ->
      if cur is null
        acc.r.unshift(acc.i)

        r: acc.r
        i: acc.i
      else
        acc.r.unshift(cur)

        r: acc.r
        i: cur
    r: []
    i: 0)
  res.r

toGuides = (indents, cursorRows = []) ->
  ind = fillInNulls(indents.map (i) ->
    if i is null
      null
    else
      Math.floor(i))
  toG(ind, 0, 0, cursorRows).guides.slice(1).map (g) ->
    length: g.length
    point: g.point.translate(new Point(0, -1))
    active: g.active
    stack: g.stack

module.exports =
  toGuides: toGuides
