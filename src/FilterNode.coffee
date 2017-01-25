React = require('react')
D = require('react-dynamics')

Sparkline = require('./Sparkline.coffee')

h = React.createElement

class Hotkeyable extends React.PureComponent
  constructor: (props) ->
    @state = { keyState: null }

    @_keyCode = props.keyCode # @todo allow dynamic keyCode property that does not confuse onUp
    @_downListener = @_onKeyDown.bind(this)
    @_upListener = @_onKeyUp.bind(this)

  componentWillMount: ->
    document.addEventListener 'keydown', @_downListener, false
    document.addEventListener 'keyup', @_upListener, false

  componentWillUnmount: ->
    document.removeEventListener 'keydown', @_downListener
    document.removeEventListener 'keyup', @_upListener

  _onKeyDown: (e) ->
    if not @state.keyState and e.which is @_keyCode
      @setState { keyState: {} }

  _onKeyUp: (e) ->
    if @state.keyState and e.which is @_keyCode
      @setState { keyState: null }

  render: ->
    @props.contents(@state.keyState)

class ToneTester extends React.PureComponent
  constructor: (props) ->
    super()

    @_frequency = props.frequency
    @_testInputNode = props.inputNode
    @_soundSource = null

  componentDidMount: ->
    if @props.on
      @_startSound()

  componentDidUpdate: ->
    if @props.on
      @_startSound()
    else
      @_stopSound()

  componentWillUnmount: ->
    @_stopSound()

  _startSound: ->
    if !@_soundSource
      context = @_testInputNode.context

      @_soundSource = context.createOscillator()
      @_soundSource.type = 'sine'
      @_soundSource.frequency.value = @props.frequency
      @_soundSource.start 0

      volumeNode = context.createGain()
      volumeNode.gain.value = 0.4 # need to temper the test tone, otherwise it clips

      @_soundSource.connect volumeNode
      volumeNode.connect @_testInputNode
      volumeNode.connect context.destination

  _stopSound: ->
    if @_soundSource
      @_soundSource.stop 0
      @_soundSource = null

  render: ->
    @props.contents(@props.on)

class FilterNode extends React.PureComponent
  constructor: (props) ->
    super()

    @state = { thresholdStatus: false }

    @_detector = props.thresholdDetector
    @_testInputNode = props.inputNode
    @_dataListener = @_onThresholdData.bind(this)

  componentWillMount: ->
    @_detector.output.on 'data', @_dataListener

  componentWillUnmount: ->
    @_detector.output.removeListener 'data', @_dataListener

  _onThresholdData: ({ time, value }) ->
    requestAnimationFrame =>
      @setState({ thresholdStatus: value })

  render: ->
    h 'div', style: {
      position: 'relative'
      display: 'inline-block'
      verticalAlign: 'middle'
      width: '195px'
      height: '40px'
    }, (
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
      }, h Sparkline, { detectorRMS: @_detector.rms, bufferSize: 10 }
    ),

    (
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
        background: if @state.thresholdStatus then '#e0ffe0' else '#fff'
        borderRadius: '5px'
      }, @_detector.rms.frequency + 'Hz'
    ),

    (
      h Hotkeyable, keyCode: @props.keyCode, contents: (keyState) => h D.Pressable, contents: (pressState) =>
        h ToneTester, frequency: @_detector.rms.frequency, inputNode: @_testInputNode, on: keyState or pressState, contents: (testerState) =>
          h 'button', style: {
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
            background: (if testerState then '#f8e8e0' else '#e0e0e0')
            cursor: 'pointer'
            border: '1px solid #c0c0c0'
            borderRadius: '5px'
            boxShadow: (if testerState then '0px 0px 10px -5px #000 inset' else '')
          }, 'TEST'
    )

module.exports = FilterNode
