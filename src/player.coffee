class Player extends Entity

  imgName: "player"

  constructor: (@world) ->
    super()

    @lane = 2
    @y = @world.height

    @speed = @world.playerSpeed || .7
    @returnSpeed = @world.returnSpeed || 1.5

    @swordSounds = (new Audio("audio/sword#{num}.wav") for num in [1 .. 4])

    @centreOn (@world.middleOfLane 2)

  update: (delta) ->
    if @world.gameOver()
      @dyingSound.play()
      @destroy()

  leftOfCentre: ->
    @centre() <= @world.middleOfLane 2

  rightOfCentre: ->
    @centre() >= @world.middleOfLane 2

  moveLeft: (delta) ->
    newPos = @x - @speed * delta

    if newPos + (@width / 2) > (@world.middleOfLane 1) and @leftOfCentre()
      @x = newPos
    else if @rightOfCentre()
      @moveToCentre(delta)

  moveRight: (delta) ->
    newPos = @x + @speed * delta

    if newPos + (@width / 2) < (@world.middleOfLane 3) and @rightOfCentre()
      @x = newPos
    else if @leftOfCentre()
      @moveToCentre(delta)

  moveToCentre: (delta) ->
    distanceToMove = @returnSpeed * delta

    if Math.abs(@distanceFromCentre()) <= distanceToMove
      @centreOn (@world.middleOfLane 2)

    if @distanceFromCentre() > 200
      console.log "asdf"
    if @distanceFromCentre() > 0
      @x -= @returnSpeed * delta
    if @distanceFromCentre() < 0
      @x += @returnSpeed * delta

  distanceFromCentre: ->
    return @centre() - (@world.middleOfLane 2)

  makeSwordNoise: ->
    choice = (array) -> array[Math.floor(Math.random() * array.length)]
    choice(@swordSounds).play()

window.Player = Player