class FallingThing extends Entity

  @y: 10

  constructor: (@world) ->
    @y = 10
    @sprite = new SpriteImage(@world, @imgFilename)

    @height = @sprite.image.height
    @width = @sprite.image.width

    @centreOn (@world.middleOfLane @lane)

  update: (delta) ->
    @y += delta * @speed * Math.log(@world.elapsedTime) / 50

    if not @touchedPlayer and @isCollidingWith(@world.player)
      @onTouchingPlayer()

  onTouchingPlayer: ->
    @destroy()
    @touchedPlayer = true


  @timeToHit: ->
    distanceToPlayer = World.height - @y
    return distanceToPlayer / @speed

window.FallingThing = FallingThing