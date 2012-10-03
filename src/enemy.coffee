class Enemy extends Entity

  y: 10
  speed: 3
  usedUpALife: false

  constructor: (@world) ->
    @sprite = new SpriteImage(@world, @imgFilename)

    @lostLifeSound = new Audio("audio/lostLife.wav")

    @height = @sprite.image.height
    @width = @sprite.image.width

    # a la Python's random.choice
    @lane = Math.floor(Math.random() * @world.numLanes) + 1

    @centreOn (@world.middleOfLane @lane)

  update: (delta) ->
    @y += delta * @speed * Math.log(@world.elapsedTime) / 50

    atPlayersHeight = @y + @height > @world.player.y
    inSameLaneAsPlayer = @lane == @world.player.lane

    if @isCollidingWith @world.player
      @destroy()

    if not @usedUpALife and @y > @world.player.y + 30
      @world.lives -= 1
      if @world.gameOver()
        @world.dyingSound.play()
      @usedUpALife = true
      @lostLifeSound.play()

window.Enemy = Enemy