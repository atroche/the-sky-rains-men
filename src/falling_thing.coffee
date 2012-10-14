class FallingThing extends Entity

  @y: 10

  constructor: (@world) ->
    super()

    @y = 10

  update: (delta) ->
    unless @stopped
      @centreOn (@world.middleOfLane @lane)
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