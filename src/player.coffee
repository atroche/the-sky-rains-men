class Player extends Entity

  imgName: "player"

  constructor: (@world) ->
    super()

    @lane = 2
    @y = 500

    @speed = @world.playerSpeed || .7
    @returnSpeed = @world.returnSpeed || 1.5

    @swordSounds = (@world.assets.core["sword#{num}"] for num in [1 .. 4])

    @centreOn (@world.middleOfLane 2)

  update: (delta) ->
    if @world.gameOver()
      @dyingSound.play()
      @destroy()

  tryToMoveTo: (newX) ->
    if newX >= (@world.middleOfLane 3)
      @x = @world.middleOfLane 3
    else if newX <= (@world.middleOfLane 1) - @width
      @x = (@world.middleOfLane 1) - @width
    else
      @x = newX

  makeSwordNoise: ->
    choice = (array) -> array[Math.floor(Math.random() * array.length)]
    choice(@swordSounds).play()

window.Player = Player