# Asset manager. Helps download and organize all your asset files.
# Is initially created with a manifest that must describe all your game assets.
# Example:
# ```coffee
# assets = new Rogue.AssetManager({
#   baseUrl: ""
#   packs:
#     core: [
#       {name:"bg1",src:"img/b1.png"}
#       {name:"bg2",src:"img/b2.png"}
#       {name:"red",src:"img/1.png"}
#       {name:"blue",src:"img/2.png"}
#       {name:"jump",src:"sound/jump.ogg",alt:"sound/jump.mp3"}
#     ]
#   preload: false
# })
# # "img/b1.png" is now available as a canvas as assets.core.bg1
# # "sound/jump.ogg"/"sound/jump.mp3" is now available as an Audio() element as assets.core.jump
# # By having sounds as both ogg and mp3 we can cover all browsers.
# ```
class AssetManager
  # AssetManager constructor
  # @param {Object} manifest a manifest declares "packs" of assets. See above example
  # @option {String} baseUrl this will be added to all source urls
  # @option {Object} packs
  # @option {Bool} preload note: If preload is set to true, and your assets load really fast, callbacks may not fire.
  constructor: (manifest) ->
    @callbacks = {load:{},complete:{},error:{}}
    @base = manifest.baseUrl or ""
    @packs = {}
    @total = @complete = 0
    for name,contents of manifest.packs
      @packs[name] = contents
      @total += contents.length
    manifest.preload and @downloadAll()
  # Download a pack manually from the manifest. If it has already been downloaded, it will not be downloaded again
  # @param {String} pack name of pack to download
  download: (pack) ->
    that = @
    contents = @packs[pack]
    unless contents?
      log 2, "Pack #{pack} does not exist"
      return false
    unless contents.loaded is contents.length
      contents.loaded = 0
      for asset in contents
        ext = asset.src.split(".").pop()
        asset.src = @base+asset.src
        asset.pack = pack
        for key,value of filetypes
          if ext in value
            asset.type = key
        unless asset.type?
          log 2,"Unknown asset type for extension: #{ext}"
          return false
        switch asset.type
          when "image"
            data = new Image()
            data.a = asset
            data.onload = ->
              canvas = util.imgToCanvas @
              a = util.mixin canvas,@a
              that.loaded a
            data.onerror = -> callback.call(that,@a,false)
            data.src = asset.src
          when "sound"
            asset.alt = @base+asset.alt
            data = new Audio()
            data.preload = "none"
            asset = util.mixin data,asset
            unless data.canPlayType codecs[ext] then asset.src = asset.alt
            asset.onerror = -> callback.call(that,asset,false)
            asset.addEventListener 'canplaythrough', -> that.loaded @
            asset.load()

  loaded: (asset) ->
    pack = @packs[asset.pack]
    @[asset.pack] ?= {}
    @[asset.pack][asset.name] = asset
    callback.call(@,asset,true)

  # Download all packs
  # It's probably preferable to set up callbacks and then downloadAll() rather than `preload: true` and hope for the best
  # unless your assets are really small. Callbacks can be set up so that the game can start running as soon as a minimum of assets
  # has been downloaded.
  downloadAll: ->
    @download key for key,val of @packs

  # Set up callbacks. You can have callbacks on the events "load","complete" and "error" for each of your packs,
  # or set pack to "all" to run for all packs. Yes that does mean you can't have callbacks on a pack named all. That's a silly name for a pack anyway
  # callbacks on the "load" event get passed the current percentage
  # @param {String} e an event to call on. Must be one of "load","complete" or "error"
  # @param {String} pack the name of the pack you want the event to apply to
  # @param {Function} fn the callback function
  on: (e,pack,fn) ->
    if e in ["load","complete","error"]
      if pack is "all"
        @["on"+e] ?= []
        @["on"+e].push fn
      else
        @callbacks[e][pack] ?= []
        @callbacks[e][pack].push fn

  callback = (asset,status) ->
    pack = @packs[asset.pack]
    percent = math.round ++pack.loaded/pack.length*100
    apercent = math.round ++@complete/@total*100
    funcs = []
    afuncs = []
    if status then s = "load" else "error"
    funcs = funcs.concat @callbacks[s][asset.pack]
    afuncs = afuncs.concat @["on"+s]
    if percent is 100 then funcs = funcs.concat @callbacks.complete[asset.pack]
    if apercent is 100 then afuncs = afuncs.concat @oncomplete
    func asset,percent for func in funcs when func
    func asset,apercent for func in afuncs when func


  filetypes =
      image: ["png","gif","jpg","jpeg","tiff"]
      sound: ["mp3","ogg"]
  codecs =
    'mp3':'audio/mpeg'
    'ogg':'audio/ogg'

window.AssetManager = AssetManager



util =
  # Makes a new canvas
  canvas: -> document.createElement("canvas")

  imgToCanvas: (i) ->
    c = @canvas()
    c.src = i.src; c.width = i.width; c.height = i.height
    cx = c.getContext "2d"
    cx.drawImage i,0,0,i.width,i.height
    c

  isArray: (value) ->
    Object::toString.call(value) is '[object Array]'

  remove: (a,val) ->
    idx = a.indexOf(val)
    idx and a.splice idx, 1

  mixin: (obj, mixin) ->
    for name, method of mixin when method isnt null
      if method.slice
        obj[name] = method.slice(0)
      else
        obj[name] = method
    obj

  IE: ->
    `//@cc_on navigator.appVersion`

math =
  # A faster round implementation
  round: (num) ->
    return (0.5 + num) | 0