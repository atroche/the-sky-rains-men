class Enemy extends FallingThing

  usedUpALife: false

  constructor: (@world, @lane) ->
    @lostLifeSound = @world.assets.core.lostLife
    super(@world)

  update: (delta) ->
    super(delta)

  onTouchingPlayer: ->
    if not @usedUpALife
      @world.lives -= 1
      if @world.gameOver()
        @world.dyingSound.play()
      @usedUpALife = true
      @lostLifeSound.play()
    super()

  @releaseTime: ->
    return 0

window.Enemy = Enemy