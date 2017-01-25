React = require('react')
D = require('react-dynamics')

Hotkeyable = require('./Hotkeyable.coffee')
ToneTester = require('./ToneTester.coffee')
Sparkline = require('./Sparkline.coffee')

h = React.createElement

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
