class SpriteImage
  ready: false

  constructor: (@world) ->
    @image = window.assets.images[imgName]

  draw: (x, y) ->
    @world.ctx.drawImage(@image, x, y)

window.SpriteImage = SpriteImage