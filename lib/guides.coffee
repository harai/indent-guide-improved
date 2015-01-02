{Point} = require 'atom'

toG = (indents, begin, depth) ->
  ptr = begin

  gs = []
  while ptr < indents.length && depth <= indents[ptr]
    if depth < indents[ptr]
      r = toG(indents, ptr, depth + 1)
      Array.prototype.push.apply(gs, r.guides)
      ptr = r.ptr
    else
      ptr++
  gs.unshift
    length: ptr - begin
    point: new Point(begin, depth)
  return {guides: gs, ptr: ptr}

toGuides = (indents) ->
  toG(indents, 0, 0).guides.slice(1).map (g) ->
    {length: g.length, point: g.point.translate(new Point(0, -1))}

module.exports =
  toGuides: toGuides
