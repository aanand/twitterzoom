init = ->
  dropper = new ImageDropper($('.drop-target'))
  zoomer  = new Zoomer($('.canvas-wrapper'))

  dropper.onImageDropped = (img) ->
    zoomer.setImage(img)

class Zoomer
  constructor: (wrapper) ->
    @wrapper = wrapper
    @width   = 1200
    @height  = 600
    @step    = 50

  initCanvas: ->
    return if @canvas?

    @canvas = $('<canvas/>')[0]
    @canvas.width  = @width
    @canvas.height = @height
    @wrapper.empty().append(@canvas)

  setImage: (img) ->
    @initCanvas()
    ctx = @canvas.getContext('2d')

    for [x, y, w, h] in @getLayers()
      ctx.drawImage(img, x, y, w, h)

  getLayers: ->
    [x, y, w, h] = [@getStartX(), @getStartY(), @getStartW(), @getStartH()]
    layers = [[x, y, w, h]]

    while w < @width or h < @height
      x -= @step
      y -= @step
      w += @step*2
      h += @step*2

      layers.unshift([x, y, w, h])

    layers

  getStartW: -> @startW ? 168
  getStartH: -> @startH ? 168
  getStartX: -> @startX ? (@width/2 - @getStartW()/2)
  getStartY: -> @startY ? (@height/2 - @getStartH()/2)

class ImageDropper
  constructor: (target) ->
    target = $(target)

    target    
      .bind 'dragover', (event) ->
        event.stopPropagation()
        event.preventDefault()
        target.addClass('dragover')

      .bind 'dragout', (event) ->
        event.stopPropagation()
        event.preventDefault()
        target.removeClass('dragover')

      .bind 'drop', (event) =>
        event.stopPropagation()
        event.preventDefault()
        target.removeClass('dragover')
        @getImage(event.originalEvent.dataTransfer.files)

  getImage: (files) ->
    reader = new FileReader
    
    reader.onload = (event) =>
      img = new Image
      img.src = event.target.result
      img.onload = =>
        @onImageDropped(img) if @onImageDropped?

    reader.readAsDataURL(files[0])

init()