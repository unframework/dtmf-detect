React = require('react')
D = require('react-dynamics')

h = React.createElement

class CoderListener extends React.PureComponent
  constructor: ({ coder }) ->
    super()

    @_coder = coder
    @_dataListener = @_onCodeData.bind(this)

  componentWillMount: ->
    @_coder.output.on 'data', @_dataListener

  componentWillUnmount: ->
    @_coder.output.removeListener 'data', @_dataListener

  _onCodeData: ({ time, value }) ->
    requestAnimationFrame =>
      @props.onCode value

  render: ->
    if @props.contents then @props.contents() else null

ResultScreen = ({ coder }) ->
  h 'div', style: {
    display: 'inline-block'
    position: 'relative'
    width: '768px'
    height: '64px'
    overflow: 'hidden',
    border: '1px solid #c0c0c0'
    borderRadius: '3px'
  }, [
    h 'span', style: {
      display: 'inline-block'
      verticalAlign: 'middle'
      fontFamily: 'Courier New, mono'
      fontSize: '32px'
      fontWeight: 'bold'
      height: '64px'
      lineHeight: '64px'
    }, (
      h D.Notice, contents: (show, render) ->
        (render (codeBuffer, Status) ->
          h D.Expirable, on: codeBuffer, delayMs: 5000, contents: (expiryState) -> h Status, on: expiryState, contents: ->
            h CoderListener, coder: coder, onCode: ((code) -> show codeBuffer + code), contents: ->
              h 'span', {}, codeBuffer
        ) or h CoderListener, coder: coder, onCode: ((code) -> show code)
    )
    h 'span', style: {
      display: 'inline-block'
      verticalAlign: 'middle'
      marginLeft: '2px'
      width: '3px'
      height: '48px'
      background: '#c0c0c0'
    }
  ]

module.exports = ResultScreen
