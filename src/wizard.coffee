class Wizard extends Enemy

  @speed: 1.5
  speed: 1.5
  imgName: "wizard"

  stoppedFor: 0
  @stopFor: 800
  stopFor: 800

  swapped: false

  constructor: (@world, @lane) ->
    @eventualLane = @lane

    @stopAt = Math.floor(Math.random() * @world.height / 2.5)

    switch @lane
      when 1
        @lane = 2
      when 2
        @lane = if Math.random() > .5 then 1 else 3
      when 3
        @lane = 2

    super(@world, @lane)

  eventualLane: ->
    return @eventual

  swapLanes: ->
    @lane = @eventualLane

    @swapped = true

  update: (delta) ->
    if @y >= @stopAt and @stoppedFor < @stopFor
      if not @swapped and @stoppedFor > @stopFor / 2
        @swapLanes()

      @stoppedFor += delta
      @stopped = true
    else
      @stopped = false

    super(delta)

  @timeToHit: ->
    return super() + @stopFor

  @releaseTime: ->
    return 5 * 1000

window.Wizard = Wizard