class Entity

  hitboxX: 0
  hitboxY: 0
  hitboxWidth: 0
  hitboxHeight: 0

  constructor: ->
    @image = @world.assets.core[@imgName]
    @width = @image.width
    @height = @image.height

  render: ->
    unless @dead
      @world.ctx.drawImage(@image, @x, @y)
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
    thisWidth = @width + @hitboxWidth
    thisHeight = @height + @hitboxHeight

    otherWidth = otherEntity.hitboxWidth or otherEntity.width
    otherHeight = otherEntity.hitboxHeight or otherEntity.height

    w = (thisWidth + otherWidth)/ 2
    h = (thisHeight + otherHeight) / 2

    thisX = @x + @hitboxX
    thisY = @y + @hitboxY

    otherY = otherEntity.y + otherEntity.hitboxY
    otherX = otherEntity.x + otherEntity.hitboxX

    # x and y distance between entities
    dx = (thisX + thisWidth / 2) - (otherX + otherWidth / 2)
    dy = (thisY + thisHeight / 2) - (otherY + otherHeight / 2)

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