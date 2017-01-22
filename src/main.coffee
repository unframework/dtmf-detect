React = require('react')
ReactDOM = require('react-dom')

FrequencyRMS = require('./FrequencyRMS.coffee')

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
    context.decodeAudioData request.response, (buffer) ->
      cb buffer

    # silly hack to make sure that screen refreshes on load
    setTimeout (->), 0

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

renderSparkline = (index, sparkline, detector, h) ->
  resolution = 10
  graphUnitPx = 3
  heightPx = (resolution + 1) * graphUnitPx
  graphWidthPx = sparkline.length * graphUnitPx
  textWidthPx = 60

  h 'div', key: index, style: {
    boxSizing: 'border-box'
    position: 'relative'
    display: 'inline-block'
    paddingLeft: graphWidthPx + 'px'
    width: (graphWidthPx + textWidthPx) + 'px'
    height: heightPx + 'px'
    background: '#f8f8f8'
    textAlign: 'center'
    lineHeight: heightPx + 'px'
  }, [
    h 'div', key: -1, style: {
      position: 'absolute'
      left: 0
      top: 0
      width: graphWidthPx + 'px'
      height: heightPx + 'px'
      background: '#eee'
    }
    for v, i in sparkline
      iv = Math.max(0, Math.min(resolution, Math.round(v * resolution)))
      h 'span', { key: i, style: {
        boxSizing: 'border-box'
        position: 'absolute'
        left: i * graphUnitPx + 'px'
        bottom: 0
        width: graphUnitPx + 'px'
        height: (iv + 1) * graphUnitPx + 'px'
        background: '#666'
        borderTop: '2px solid #444'
        transition: 'height 0.1s'
      } }, ''
    detector.frequency + 'Hz'
  ]

renderBank = (bankIndex, nodeList, h) ->
  widthPx = 100
  nodeHeightPx = 40
  captionHeightPx = 20

  h 'div', key: bankIndex, style: {
    position: 'relative'
    display: 'inline-block'
    width: widthPx + 'px'
    height: (captionHeightPx + nodeList.length * nodeHeightPx) + 'px'
  }, [
    h 'div', key: -1, style: {
      position: 'absolute'
      left: 0
      right: 0
      top: 0
      height: captionHeightPx + 'px'
      lineHeight: captionHeightPx + 'px'
      textAlign: 'center'
    }, 'Set ' + bankIndex
    for lineNode, i in nodeList
      h 'div', key: i, style: {
        position: 'absolute'
        left: 0
        right: 0
        top: (captionHeightPx + i * nodeHeightPx) + 'px'
        height: nodeHeightPx + 'px'
        lineHeight: nodeHeightPx + 'px'
        textAlign: 'center'
      }, lineNode
  ]

document.addEventListener 'DOMContentLoaded', ->
  document.body.style.textAlign = 'center';

  setInterval ->
    for sparklineSet, i in sparklineSetList
      for sparkline, j in sparklineSet
        detector = bankList[i][j]
        sparkline.shift()
        sparkline.push(4 * detector.rmsValue)

    ReactDOM.render(React.createElement(Demo), root)
  , 100

  h = React.createElement

  Demo = () ->
    h 'div', style: {
      display: 'inline-block'
      marginTop: '50px'
    }, [
      for keyName, i in keyList
        do (i) ->
          h 'button', key: i, style: { fontSize: '120%' }, onClick: (-> runSample i), 'Key: ' + keyName
      for sparklineSet, setIndex in sparklineSetList
        lineNodes = for sparkline, sparklineIndex in sparklineSet
          detector = bankList[setIndex][sparklineIndex]
          renderSparkline sparklineIndex, sparkline, detector, h

        renderBank setIndex, lineNodes, h
    ]

  root = document.createElement('div')
  document.body.appendChild(root)

  ReactDOM.render(React.createElement(Demo), root)
