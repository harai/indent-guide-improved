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
  unless depth is 0
    gs.unshift
      length: ptr - begin
      point: new Point(begin, depth - 1)
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

toGuides = (indents, cursorRows) ->
  ind = fillInNulls indents.map (i) -> if i is null then null else Math.floor(i)
  toG(ind, 0, 0, cursorRows).guides

getVirtualIndent = (getIndentFn, row, lastRow) ->
  for i in [row..lastRow]
    ind = getIndentFn(i)
    return ind if ind?
  0

uniq = (values) ->
  newVals = []
  last = null
  for v in values
    if newVals.length is 0 or last isnt v
      newVals.push(v)
    last = v
  newVals

mergeCropped = (guides, above, below, height) ->
  guides.forEach (g) ->
    if g.point.row is 0
      if g.point.column in above.active
        g.active = true
      if g.point.column in above.stack
        g.stack = true
    if height < g.point.row + g.length
      if g.point.column in below.active
        g.active = true
      if g.point.column in below.stack
        g.stack = true
  guides

supportingIndents = (visibleLast, lastRow, getIndentFn) ->
  return [] if getIndentFn(visibleLast)?
  indents = []
  count = visibleLast + 1
  while count <= lastRow
    indent = getIndentFn(count)
    indents.push(indent)
    break if indent?
    count++
  indents

getGuides = (visibleFrom, visibleTo, lastRow, cursorRows, getIndentFn) ->
  visibleLast = Math.min(visibleTo, lastRow)
  visibleIndents = [visibleFrom..visibleLast].map getIndentFn
  support = supportingIndents(visibleLast, lastRow, getIndentFn)
  guides = toGuides(
    visibleIndents.concat(support), cursorRows.map((c) -> c - visibleFrom))
  above = statesAboveVisible(cursorRows, visibleFrom - 1, getIndentFn, lastRow)
  below = statesBelowVisible(cursorRows, visibleLast + 1, getIndentFn, lastRow)
  mergeCropped(guides, above, below, visibleLast - visibleFrom)

statesInvisible = (cursorRows, start, getIndentFn, lastRow, isAbove) ->
  if (if isAbove then start < 0 else lastRow < start)
    return {
      stack: []
      active: []
    }
  cursors = if isAbove
    uniq(cursorRows.filter((r) -> r <= start).sort(), true).reverse()
  else
    uniq(cursorRows.filter((r) -> start <= r).sort(), true)
  active = []
  stack = []
  minIndent = Number.MAX_VALUE
  for i in (if isAbove then [start..0] else [start..lastRow])
    ind = getIndentFn(i)
    minIndent = Math.min(minIndent, ind) if ind?
    break if cursors.length is 0 or minIndent is 0
    if cursors[0] is i
      cursors.shift()
      vind = getVirtualIndent(getIndentFn, i, lastRow)
      minIndent = Math.min(minIndent, vind)
      active.push(vind - 1) if vind is minIndent
      stack = [0..minIndent - 1] if stack.length is 0
  stack: uniq(stack.sort())
  active: uniq(active.sort())

statesAboveVisible = (cursorRows, start, getIndentFn, lastRow) ->
  statesInvisible(cursorRows, start, getIndentFn, lastRow, true)

statesBelowVisible = (cursorRows, start, getIndentFn, lastRow) ->
  statesInvisible(cursorRows, start, getIndentFn, lastRow, false)

module.exports =
  toGuides: toGuides
  getGuides: getGuides
  uniq: uniq
  statesAboveVisible: statesAboveVisible
  statesBelowVisible: statesBelowVisible
