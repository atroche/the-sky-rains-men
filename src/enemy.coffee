class Enemy extends FallingThing

  usedUpALife: false

  constructor: (@world, @lane) ->
    @lostLifeSound = @world.assets.core.lostLife
    super(@world)

  checkForPlayerDeath: ->
    if not @usedUpALife and @y > @world.player.y + 30
      @world.lives -= 1
      if @world.gameOver()
        @world.dyingSound.play()
      @usedUpALife = true
      @lostLifeSound.play()

  update: (delta) ->
    @checkForPlayerDeath()
    super(delta)

  onTouchingPlayer: ->
    @world.player.makeSwordNoise()
    super()

window.Enemy = Enemy