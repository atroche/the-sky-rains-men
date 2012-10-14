class Bat extends Enemy

  @speed: 3
  speed: 3
  imgName: "bat"

  stoppedFor: 0
  stopFor: 300

  constructor: (@world, @lane) ->
    @stopAt = Math.floor(Math.random() * @world.height / 2)
    super(@world, @lane)

  update: (delta) ->
    if @y >= @stopAt and @stoppedFor < @stopFor
      @stoppedFor += delta
      @stopped = true
    else
      @stopped = false

    super(delta)

  timeToHit: ->
    return super() + @stopFor

  @releaseTime: ->
    return 5 * 1000

window.Bat = Bat