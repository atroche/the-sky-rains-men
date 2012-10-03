class SpriteImage
  ready: false

  constructor: (@world, url) ->
    image = new Image
    image.src = url
    image.onload = => @ready = true
    @image = image

  draw: (x, y) ->
    if @ready
      @world.ctx.drawImage(@image, x, y)

window.SpriteImage = SpriteImage