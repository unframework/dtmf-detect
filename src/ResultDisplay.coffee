React = require('react')

h = React.createElement

class CodeBuffer extends React.PureComponent
  constructor: ({ coder }) ->
    super()

    @state = { codeBuffer: [] }

    @_coder = coder
    @_dataListener = @_onCodeData.bind(this)

  componentWillMount: ->
    @_coder.output.on 'data', @_dataListener

  componentWillUnmount: ->
    @_coder.output.removeListener 'data', @_dataListener

  _onCodeData: ({ time, value }) ->
    requestAnimationFrame =>
      @setState (state) => { codeBuffer: state.codeBuffer.concat [ value ] }

  render: ->
    return @props.contents(@state.codeBuffer)

ResultScreen = ({ coder }) ->
  h 'div', style: {
    display: 'inline-block'
    position: 'relative'
    width: '768px'
    height: '64px'
    overflow: 'hidden',
    border: '1px solid #c0c0c0'
    borderRadius: '3px'
  }, h CodeBuffer, coder: coder, contents: (codeBuffer) =>
    h 'span', style: {
      fontFamily: 'Courier New, mono'
      fontSize: '32px'
      fontWeight: 'bold'
      lineHeight: '64px'
    }, codeBuffer.join ''

module.exports = ResultScreen
