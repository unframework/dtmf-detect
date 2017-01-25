React = require('react')
ReactDOM = require('react-dom')

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

document.addEventListener 'DOMContentLoaded', ->
  document.body.style.textAlign = 'center';

  h = React.createElement

  Demo = () ->
    h 'div', style: {
      display: 'inline-block'
    },
    (
      h InputPanel, inputNode: inputNode
    ),
    (
      h 'div', style: { height: '10px' }
    ),
    (
      h BasicScreen, loBank: bankList[0], hiBank: bankList[1], coder: coder, inputNode: inputNode, widthPx: 768, heightPx: 512
    ),
    # (
    #   h GridScreen, loBank: bankList[0], hiBank: bankList[1], keyCodeListSet: keyCodeListSet, coder: coder, inputNode: inputNode, widthPx: 768, heightPx: 512
    # ),
    (
      h 'div', style: { height: '10px' }
    ),
    (
      h ResultDisplay, { coder: coder }
    )

  root = document.createElement('div')
  document.body.appendChild(root)

  ReactDOM.render(React.createElement(Demo), root)
