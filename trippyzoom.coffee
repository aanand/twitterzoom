init = ->
  dropper = new ImageDropper($('.drop-target'))
  dropper.onImageDropped = (img) ->
    console.log(img)

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