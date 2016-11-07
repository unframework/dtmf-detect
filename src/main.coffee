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

# http://dsp.stackexchange.com/questions/15594/how-can-i-reduce-noise-errors-when-detecting-dtmf-with-the-goertzel-algorithm
# [ 697, 770, 852, 941 ]
# [ 1209, 1336, 1477, 1633 ]
class FreqRMS
  constructor: (context, freq) ->
    freqFilter = context.createBiquadFilter()
    freqFilter.channelCount = 1
    freqFilter.type = 'bandpass'
    freqFilter.Q.value = 300 # seems small enough of a band for given range
    freqFilter.frequency.value = freq

    rmsComputer = context.createScriptProcessor(1024, 1, 1)
    rmsComputer.onaudioprocess = (e) =>
      channelData = e.inputBuffer.getChannelData(0)

      sum = 0
      for x in channelData
        sum += x * x

      @rmsValue = Math.sqrt(sum / channelData.length)

    freqFilter.connect rmsComputer
    rmsComputer.connect context.destination

    @audioNode = freqFilter
    @rmsValue = 0

bankList = for freqSet in [ [ 697, 770, 852, 941 ], [ 1209, 1336, 1477 ] ]
  for freq in freqSet
    new FreqRMS(context, freq)

sparklineSetList = for bank in bankList
  for detector in bank
    0 for [ 0 ... 10 ]

runSample = ->
  soundSource = context.createBufferSource()
  soundSource.buffer = soundBuffer
  soundSource.start 0

  for bank in bankList
    for detector in bank
      soundSource.connect detector.audioNode

  soundSource.connect context.destination

vdomLive (renderLive) ->
  document.body.style.textAlign = 'center';

  setInterval ->
    for sparklineSet, i in sparklineSetList
      for sparkline, j in sparklineSet
        detector = bankList[i][j]
        sparkline.shift()
        sparkline.push(detector.rmsValue)
  , 100

  liveDOM = renderLive (h) ->
    h 'div', {
      style: {
        display: 'inline-block'
        marginTop: '50px'
      }
    }, [
      h 'button', { onclick: runSample }, 'Hej!'
      for sparklineSet, setIndex in sparklineSetList
        lineNodes = for sparkline in sparklineSet
          h 'div', [
            '['
            for v in sparkline
              iv = Math.min(10, Math.round(40 * v))
              h 'span', { style: {
                display: 'inline-block'
                width: '2px'
                height: '1px'
                background: '#444'
                borderTop: (10 - iv) + 'px solid #eee'
                borderBottom: iv + 'px solid #666'
              } }, ''
            ']'
          ]

        [ h('hr'), h 'div', 'Set ' + setIndex ].concat lineNodes
    ]

  document.body.appendChild liveDOM
