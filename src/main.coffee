React = require('react')
ReactDOM = require('react-dom')
D = require('react-dynamics')

FrequencyRMS = require('./FrequencyRMS.coffee')
FilterThresholdDetector = require('./FilterThresholdDetector.coffee')
BankSelector = require('./BankSelector.coffee')
Coder = require('./Coder.coffee')
Collector = require('./Collector.coffee')
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

inputCompressor = context.createDynamicsCompressor()
inputCompressor.threshold.value = -10
inputCompressor.knee.value = 1
inputCompressor.ratio.value = 20
inputCompressor.attack.value = 0
inputCompressor.release.value = 0.1

for bank in bankList
  for detector in bank
    inputCompressor.connect detector.rms.audioNode

inputNode = context.createGain()
inputNode.gain.value = 8

inputNode.connect inputCompressor

previewNode = context.createGain()
previewNode.connect context.destination

soloNodeStack = []

addSoloNode = (soloNode) ->
  if soloNodeStack.indexOf(soloNode) isnt -1
    throw new Error 'already tracked as solo node'

  soloNodeStack.push soloNode
  previewNode.gain.value = 0

  soloNode.connect context.destination

removeSoloNode = (soloNode) ->
  nodeIndex = soloNodeStack.indexOf(soloNode)

  if nodeIndex is -1
    throw new Error 'not tracked as solo node'

  soloNode.disconnect context.destination

  soloNodeStack.splice nodeIndex, 1
  if soloNodeStack.length is 0
    previewNode.gain.value = 1

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
      h D.Linkable, path: '/banks', (banksNavState) -> h D.Linkable, path: '/grid', (gridNavState) ->
        h 'div', style: { display: 'inline-block', position: 'relative' },
          (
            h 'div', style: { position: 'absolute', zIndex: 1, left: '5px', bottom: '5px' },
              (h 'a', href: '#/', style: { display: 'inline-block', margin: '0 5px', fontWeight: if not banksNavState and not gridNavState then 'bold' else null }, 'Main'),
              (h 'a', href: '#/banks', style: { display: 'inline-block', margin: '0 5px', fontWeight: if banksNavState then 'bold' else null }, 'Banks'),
              (h 'a', href: '#/grid', style: { display: 'inline-block', margin: '0 5px', fontWeight: if gridNavState then 'bold' else null }, 'Grid')
          ),
          if banksNavState
            h Collector,
              property: 'input',
              onAdd: addSoloNode,
              onRemove: removeSoloNode,
              contents: (SoloNodeContext) ->
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
