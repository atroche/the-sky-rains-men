class Enemy extends FallingThing

  usedUpALife: false

  constructor: (@world) ->
    @lostLifeSound = new Audio("audio/lostLife.wav")
    super(@world)

  update: (delta) ->
    if not @usedUpALife and @y > @world.player.y + 30
      @world.lives -= 1
      if @world.gameOver()
        @world.dyingSound.play()
      @usedUpALife = true
      @lostLifeSound.play()

    super(delta)

  onTouchingPlayer: ->
    @world.player.makeSwordNoise()
    super()

window.Enemy = Enemy