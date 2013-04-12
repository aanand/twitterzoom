init = ->
  dropper = new ImageDropper($('.drop-target'))
  options = new ZoomerOptions($('.controls'))
  zoomer  = new Zoomer($('.canvas-wrapper'), options)

  dropper.onImageDropped = (img) ->
    options.image(img)

class ZoomerOptions
  constructor: (element) ->
    @element = $(element)

    @canvasW = ko.observable('520')
    @canvasH = ko.observable('260')
    @startW  = ko.observable('73')
    @startH  = ko.observable('73')
    @startX  = ko.observable('223')
    @startY  = ko.observable('24')
    @step    = ko.observable('24')
    @image   = ko.observable()

    ko.applyBindings(this, @element.get(0))

    @downloadButton = @element.find('button.download-image')
    @image.subscribe => @updateDownloadButton()
    @updateDownloadButton()

  updateDownloadButton: ->
    enable = @image()?

    @downloadButton
      .attr('disabled', !enable)
      .toggleClass('btn-primary', enable)

class Zoomer
  constructor: (wrapper, options) ->
    @wrapper = wrapper
    @options = options

    observables = "canvasW canvasH startW startH startX startY step image".split(/\s+/)
    for property in observables
      options[property].subscribe => @render()

    options.downloadButton.click => @download()

  render: ->
    img = @options.image()
    return unless img?

    @canvas = $('<canvas/>')[0]
    @canvas.width  = @getCanvasW()
    @canvas.height = @getCanvasH()
    @wrapper.empty().append(@canvas)

    ctx = @canvas.getContext('2d')

    for [x, y, w, h] in @getLayers()
      ctx.drawImage(img, x, y, w, h)

  download: ->
    window.open(@canvas.toDataURL())

  getLayers: ->
    [maxW, maxH, step] = [@getCanvasW(), @getCanvasH(), @getStep()]
    [x, y, w, h] = [@getStartX(), @getStartY(), @getStartW(), @getStartH()]
    layers = [[x, y, w, h]]

    while x > 0 or y > 0 or x+w < maxW or y+h < maxH
      x -= step
      y -= step
      w += step*2
      h += step*2

      layers.unshift([x, y, w, h])

    layers

  getCanvasW: -> window.parseInt(@options.canvasW())
  getCanvasH: -> window.parseInt(@options.canvasH())
  getStartW:  -> window.parseInt(@options.startW())
  getStartH:  -> window.parseInt(@options.startH())
  getStartX:  -> if @options.startX() then window.parseInt(@options.startX()) else (@getCanvasW()/2 - @getStartW()/2)
  getStartY:  -> if @options.startY() then window.parseInt(@options.startY()) else (@getCanvasH()/2 - @getStartH()/2)
  getStep:    -> window.parseInt(@options.step())

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