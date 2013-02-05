class ExtraLife extends FallingThing

  speed: 3
  imgFilename: "img/extra_life.png"

  onTouchingPlayer: ->
    @world.lives += 1
    super()

  @probability: ->
    return 0.2

window.ExtraLife = ExtraLife