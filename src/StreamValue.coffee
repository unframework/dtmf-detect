React = require('react')

class StreamValue extends React.PureComponent
  constructor: (props) ->
    super()

    @state = { latestValue: null }

    @_stream = props.stream
    @_dataListener = @_onThresholdData.bind(this)

  componentWillMount: ->
    @_stream.on 'data', @_dataListener

  componentWillUnmount: ->
    @_stream.removeListener 'data', @_dataListener

  _onThresholdData: (data) ->
    # @todo debounce fast updates
    requestAnimationFrame =>
      @setState({ latestValue: data })

  render: ->
    @props.contents(@state.latestValue)

module.exports = StreamValue
