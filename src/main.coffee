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

runSample = (index) ->
  soundSource = context.createBufferSource()
  soundSource.buffer = soundBufferList[index]
  soundSource.start 0

  for bank in bankList
    for detector in bank
      soundSource.connect detector.audioNode

  soundSource.connect context.destination

class Sparkline extends React.PureComponent
  constructor: (props) ->
    super()

    @_detectorRMSNode = props.detectorRMSNode
    @_series = (0 for [ 0 ... 10 ])
    @_unmounted = false

  _processFrame: ->
    @_series.shift()
    @_series.push(4 * @_detectorRMSNode.rmsValue)

  componentDidMount: ->
    intervalId = setInterval =>
      if @_unmounted
        clearInterval intervalId
      else
        @_processFrame()
        @forceUpdate()
    , 100

  componentWillUnmount: ->
    @_unmounted = true

  render: ->
    h = React.createElement
    resolution = 10
    graphUnitPx = 3
    heightPx = (resolution + 1) * graphUnitPx
    graphWidthPx = @_series.length * graphUnitPx
    textWidthPx = 60

    h 'div', style: {
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
      for v, i in @_series
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
      @_detectorRMSNode.frequency + 'Hz'
    ]

Bank = ({ label, bank }) ->
  h = React.createElement
  widthPx = 100
  nodeHeightPx = 40
  captionHeightPx = 20

  h 'div', style: {
    position: 'relative'
    display: 'inline-block'
    width: widthPx + 'px'
    height: (captionHeightPx + bank.length * nodeHeightPx) + 'px'
  }, [
    h 'div', key: -1, style: {
      position: 'absolute'
      left: 0
      right: 0
      top: 0
      height: captionHeightPx + 'px'
      lineHeight: captionHeightPx + 'px'
      textAlign: 'center'
    }, label
    for detector, i in bank
      h 'div', key: i, style: {
        position: 'absolute'
        left: 0
        right: 0
        top: (captionHeightPx + i * nodeHeightPx) + 'px'
        height: nodeHeightPx + 'px'
        lineHeight: nodeHeightPx + 'px'
        textAlign: 'center'
      }, h Sparkline, { detectorRMSNode: detector }
  ]

document.addEventListener 'DOMContentLoaded', ->
  document.body.style.textAlign = 'center';

  h = React.createElement

  Demo = () ->
    h 'div', style: {
      display: 'inline-block'
      marginTop: '50px'
    }, [
      for keyName, i in keyList
        do (i) ->
          h 'button', key: i, style: { fontSize: '120%' }, onClick: (-> runSample i), 'Key: ' + keyName
      for bank, bankIndex in bankList
        h Bank, label: 'Set ' + bankIndex, bank: bank
    ]

  root = document.createElement('div')
  document.body.appendChild(root)

  ReactDOM.render(React.createElement(Demo), root)
