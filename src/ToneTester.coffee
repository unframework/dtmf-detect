React = require('react')

class ToneTester extends React.PureComponent
  constructor: (props) ->
    super()

    @_frequency = props.frequency
    @_testInputNode = props.inputNode
    @_previewNode = props.previewNode
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
      volumeNode.connect @_previewNode

  _stopSound: ->
    if @_soundSource
      @_soundSource.stop 0
      @_soundSource = null

  render: ->
    @props.contents(@props.on)

module.exports = ToneTester
