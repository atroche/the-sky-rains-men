class Entity

  render: ->
    unless @dead
      @sprite.draw(@x, @y)
      if @world.showHitBoxes
        @world.ctx.strokeStyle = "white"
        @world.ctx.strokeRect(@x, @y, @width, @height)

  destroy: ->
    @dead = true

  centreOn: (centreX) ->
    @x = centreX - (@width / 2)

  centre: ->
    return @x + @width / 2

  # via https://github.com/mdlawson/rogue/blob/master/src/collision.coffee#L3
  isCollidingWith: (otherEntity) ->
    w = (@width + otherEntity.width)/ 2
    h = (@height + otherEntity.height) / 2

    # x and y distance between entities
    dx = (@x + @width / 2) - (otherEntity.x + otherEntity.width / 2)
    dy = (@y + @height / 2) - (otherEntity.y + otherEntity.height / 2)

    if Math.abs(dx) <= w and Math.abs(dy) <= h
      wy = w * dy
      hx = h * dx

      if wy > hx
        if wy > -hx then dir = "top" else dir = "left"
      else
        if wy > -hx then dir = "right" else dir ="bottom"

      px = w - (if dx < 0 then -dx else dx)
      py = h - (if dy < 0 then -dy else dy)
      return {"dir": dir,"pv": [(if dx < 0 then -px else px),(if dy < 0 then -py else py)]}
    return false

window.Entity = Entity