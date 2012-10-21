class Treasure extends FallingThing

  @speed: 3
  speed: 3
  imgName: "treasure"

  constructor: (@world, @lane) ->
    super(@world)

  onTouchingPlayer: ->
    @world.score += 1
    super()

window.Treasure = Treasure