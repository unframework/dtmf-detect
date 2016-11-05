vdomLive = require('vdom-live')

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

soundBuffer = null

loadData = (url, cb) ->
  request = new XMLHttpRequest()
  request.open 'GET', url, true
  request.responseType = 'arraybuffer'

  request.onload = ->
    done = false

    context.decodeAudioData request.response, (buffer) ->
      done = true
      cb buffer

    # silly hack to make sure that screen refreshes on load
    intervalId = setInterval (->
      if done
        clearInterval intervalId
    ), 300

  request.send();

loadData 'dtmf.mp3', (data) ->
  soundBuffer = data

analyser = context.createAnalyser()
analyser.fftSize = 512

runSample = ->
  soundSource = context.createBufferSource()
  soundSource.buffer = soundBuffer
  soundSource.start 0
  soundSource.connect analyser
  soundSource.connect context.destination

vdomLive (renderLive) ->
  frequencyData = new Uint8Array analyser.frequencyBinCount

  setInterval ->
    analyser.getByteFrequencyData frequencyData
  , 100

  document.body.style.textAlign = 'center';
  liveDOM = renderLive (h) ->
    h 'div', {
      style: {
        display: 'inline-block'
        position: 'relative'
        marginTop: '50px'
        width: analyser.frequencyBinCount * 1 + 'px'
        height: 255 + 'px'
      }
    }, ((h 'var', style: { position: 'absolute', display: 'block', background: 'black', width: '1px', height: '1px', bottom: x + 'px', left: i * 1 + 'px' }) for x, i in frequencyData).concat [
      h 'button', { onclick: runSample }, 'Hej!'
    ]

  document.body.appendChild liveDOM
