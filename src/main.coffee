vdomLive = require('vdom-live')

FrequencyRMS = require('./FrequencyRMS')

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

keyList = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'Star', 'Pound' ]

soundBufferList = for x, i in keyList
  do (x, i) ->
    loadData 'tones/dtmf' + x + '.mp3', (data) ->
      soundBufferList[i] = data

  null

# http://dsp.stackexchange.com/questions/15594/how-can-i-reduce-noise-errors-when-detecting-dtmf-with-the-goertzel-algorithm
bankList = for freqSet in [ [ 697, 770, 852, 941 ], [ 1209, 1336, 1477 ] ]
  for freq in freqSet
    new FrequencyRMS(context, freq)

sparklineSetList = for bank in bankList
  for detector in bank
    0 for [ 0 ... 10 ]

runSample = (index) ->
  soundSource = context.createBufferSource()
  soundSource.buffer = soundBufferList[index]
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
      for keyName, i in keyList
        do (i) ->
          h 'button', { style: { fontSize: '120%' }, onclick: -> runSample i }, 'Key: ' + keyName
      for sparklineSet, setIndex in sparklineSetList
        lineNodes = for sparkline, sparklineIndex in sparklineSet
          detector = bankList[setIndex][sparklineIndex]
          h 'div', [
            '['
            for v in sparkline
              iv = Math.min(10, Math.round(40 * v))
              h 'span', { style: {
                display: 'inline-block'
                width: '2px'
                height: '2px'
                background: '#444'
                borderTop: (10 - iv) * 2 + 'px solid #eee'
                borderBottom: iv * 2 + 'px solid #666'
              } }, ''
            '] ' + detector.frequency + 'Hz'
          ]

        [ h('hr'), h 'div', 'Set ' + setIndex ].concat lineNodes
    ]

  document.body.appendChild liveDOM
