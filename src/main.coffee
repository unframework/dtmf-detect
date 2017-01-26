React = require('react')
ReactDOM = require('react-dom')
D = require('react-dynamics')

FrequencyRMS = require('./FrequencyRMS.coffee')
FilterThresholdDetector = require('./FilterThresholdDetector.coffee')
BankSelector = require('./BankSelector.coffee')
Coder = require('./Coder.coffee')
InputPanel = require('./InputPanel.coffee')
BasicScreen = require('./BasicScreen.coffee')
BankScreen = require('./BankScreen.coffee')
GridScreen = require('./GridScreen.coffee')
ResultDisplay = require('./ResultDisplay.coffee')

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

# http://dsp.stackexchange.com/questions/15594/how-can-i-reduce-noise-errors-when-detecting-dtmf-with-the-goertzel-algorithm
bankList = for freqSet in [ [ 697, 770, 852, 941 ], [ 1209, 1336, 1477 ] ]
  for freq in freqSet
    new FilterThresholdDetector(new FrequencyRMS(context, freq))

coder = new Coder(new BankSelector(bankList[0]), new BankSelector(bankList[1]), [
  '1', '4', '7', '*'
  '2', '5', '8', '0'
  '3', '6', '9', '#'
])

keyCodeListSet = [
  [ 49, 50, 51, 52 ]
  [ 81, 87, 69, 82 ]
]

inputNode = context.createDelay()

for bank in bankList
  for detector in bank
    inputNode.connect detector.rms.audioNode

previewNode = context.createGain()
previewNode.connect context.destination

currentSoloNode = null

createSoloNode = ->
  soloNode = context.createGain()
  soloNode.connect context.destination

  previewNode.gain.value = 0
  currentSoloNode = soloNode

clearSoloNode = (soloNode) ->
  soloNode.disconnect()

  if currentSoloNode is soloNode
    currentSoloNode = null
    previewNode.gain.value = 1

class SoloNodeContext extends React.PureComponent
  constructor: () ->
    super()

    @_soloNode = null

  componentWillMount: ->
    if @props.on
      @_setupNode()

  componentWillReceiveProps: (nextProps) ->
    if @props.on isnt nextProps.on
      if @props.on
        @_cleanupNode()

      if nextProps.on
        @_setupNode()

  componentWillUnmount: ->
    if @props.on
      @_cleanupNode()

  _setupNode: ->
    if @_soloNode
      throw new Error 'node already set'

    @_soloNode = createSoloNode()

  _cleanupNode: ->
    if not @_soloNode
      throw new Error 'node not set'

    clearSoloNode @_soloNode
    @_soloNode = null

  render: ->
    @props.contents @_soloNode

document.addEventListener 'DOMContentLoaded', ->
  document.body.style.textAlign = 'center';

  h = React.createElement

  Demo = () ->
    h 'div', style: {
      display: 'inline-block'
    },
    (
      h InputPanel, inputNode: inputNode, previewNode: previewNode
    ),
    (
      h 'div', style: { height: '10px' }
    ),
    (
      h D.Linkable, path: '/banks', contents: (banksNavState) -> h D.Linkable, path: '/grid', contents: (gridNavState) ->
        h 'div', style: { display: 'inline-block', position: 'relative' },
          (
            h 'div', style: { position: 'absolute', zIndex: 1, left: '5px', bottom: '5px' },
              (h 'a', href: '#/', style: { display: 'inline-block', margin: '0 5px', fontWeight: if not banksNavState and not gridNavState then 'bold' else null }, 'Main'),
              (h 'a', href: '#/banks', style: { display: 'inline-block', margin: '0 5px', fontWeight: if banksNavState then 'bold' else null }, 'Banks'),
              (h 'a', href: '#/grid', style: { display: 'inline-block', margin: '0 5px', fontWeight: if gridNavState then 'bold' else null }, 'Grid')
          ),
          if banksNavState
            h BankScreen,
              bankList: bankList
              keyCodeListSet: keyCodeListSet
              inputNode: inputNode
              previewNode: previewNode
              SoloNodeContext: SoloNodeContext
              widthPx: 768
              heightPx: 400
          else if gridNavState
            h GridScreen,
              loBank: bankList[0]
              hiBank: bankList[1]
              keyCodeListSet: keyCodeListSet
              coder: coder
              inputNode: inputNode
              previewNode: previewNode
              widthPx: 768
              heightPx: 400
          else
            h BasicScreen,
              loBank: bankList[0]
              hiBank: bankList[1]
              coder: coder
              inputNode: inputNode
              previewNode: previewNode
              widthPx: 768
              heightPx: 400
    ),
    (
      h 'div', style: { height: '10px' }
    ),
    (
      h ResultDisplay, { coder: coder }
    )

  root = document.createElement('div')
  document.body.appendChild(root)

  ReactDOM.render(React.createElement(Demo), root)
