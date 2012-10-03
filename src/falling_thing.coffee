class FallingThing extends Entity

  y: 10

  constructor: (@world) ->
    @sprite = new SpriteImage(@world, @imgFilename)

    @height = @sprite.image.height
    @width = @sprite.image.width

    # a la Python's random.choice
    @lane = Math.floor(Math.random() * @world.numLanes) + 1

    @centreOn (@world.middleOfLane @lane)

  update: (delta) ->
    @y += delta * @speed * Math.log(@world.elapsedTime) / 50

    if not @touchedPlayer and @isCollidingWith(@world.player)
      @onTouchingPlayer()

  onTouchingPlayer: ->
    @destroy()
    @touchedPlayer = true


window.FallingThing = FallingThing