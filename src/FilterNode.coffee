React = require('react')

Sparkline = require('./Sparkline.coffee')

h = React.createElement

class FilterNode extends React.PureComponent
  constructor: (props) ->
    super()

    @_detectorRMSNode = props.detectorRMSNode
    @_testInputNode = props.testInputNode

  _playTestTone: ->
    context = @_testInputNode.context

    soundSource = context.createOscillator()
    soundSource.type = 'sine'
    soundSource.frequency.value = @_detectorRMSNode.frequency
    soundSource.start 0
    soundSource.stop context.currentTime + 1.2

    volumeNode = context.createGain()
    volumeNode.gain.value = 0.5 # need to temper the test tone, otherwise it clips

    soundSource.connect volumeNode
    volumeNode.connect @_testInputNode

  render: ->
    h 'div', style: {
      position: 'relative'
      display: 'inline-block'
      verticalAlign: 'middle'
      width: '195px'
      height: '40px'
    }, [
      h 'div', style: {
        boxSizing: 'border-box'
        position: 'absolute'
        top: '0px'
        right: '0px'
        padding: '5px'
        width: '60px'
        height: '40px'
        background: '#c0c0c0'
        borderRadius: '5px'
      }, h Sparkline, { detectorRMSNode: @_detectorRMSNode, bufferSize: 10 }

      h 'span', style: {
        position: 'absolute'
        top: '0px'
        left: '45px'
        fontFamily: 'Courier New, mono'
        fontWeight: 'bold'
        color: '#808080'
        width: '80px'
        lineHeight: '38px'
        textAlign: 'center'
        border: '1px solid #c0c0c0'
        borderRadius: '5px'
      }, @_detectorRMSNode.frequency + 'Hz'

      h 'button', onClick: (=> @_playTestTone()), style: {
        boxSizing: 'border-box'
        position: 'absolute'
        top: '50%'
        left: '0px'
        marginTop: '-15px'
        width: '40px'
        height: '30px'
        padding: '0'
        fontFamily: 'Courier New, mono'
        fontWeight: 'bold'
        fontSize: '12px'
        color: '#808080'
        lineHeight: '28px'
        textAlign: 'center'
        background: '#e0e0e0'
        cursor: 'pointer'
        border: '1px solid #c0c0c0'
        borderRadius: '5px'
      }, 'TEST'
    ]

module.exports = FilterNode
