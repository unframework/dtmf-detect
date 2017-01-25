React = require('react')
D = require('react-dynamics')

h = React.createElement

getUserMediaPromise = ->
  new Promise (resolve, reject) ->
    navigator.getUserMedia { audio: true }, ((stream) -> resolve stream), ((error) -> reject error)

MicrophoneRequestButton = ({ onInputStream }) ->
  h D.Submittable, action: (-> getUserMediaPromise()), onSuccess: ((v) -> onInputStream v), contents: (error, isPending, invoke) ->
    h 'div', style: {
      display: 'inline-block'
      verticalAlign: 'middle'
      position: 'relative'
    },
    (
      h 'button', disabled: isPending, onClick: invoke, 'Start Microphone'
    ),
    (
      h D.Expirable, on: error, delayMs: 3000, contents: (errorExpiryState) -> errorExpiryState and h 'span', style: {
        position: 'absolute'
        marginBottom: '5px'
        bottom: '100%'
        left: '-100%'
        right: '-100%'
        textAlign: 'middle'
      }, h 'span', style: {
        display: 'inline-block'
        lineHeight: '24px'
        color: '#f00'
        padding: '0 10px'
        background: '#fff0f0'
        borderRadius: '3px'
      }, (if error.name then error.name + ' (' + error.message + ')' else error.toString())
    )

class MicrophoneStreamStatus extends React.PureComponent
  constructor: ({ stream }) ->
    super()

    @state = { isActive: true } # @todo assert readyState of the track?

    @_streamTrack = stream.getTracks()[0] # @todo assert just one track?
    @_endedListener = this._onEnded.bind(this)

  componentWillMount: ->
    @_streamTrack.addEventListener 'ended', @_endedListener, false

  componentWillUnmount: ->
    @_streamTrack.removeEventListener 'ended', @_endedListener

  _onEnded: ->
    @setState { isActive: false }

  render: ->
    @props.contents @state.isActive

InputPanel = ({ onInputStream }) ->
  h D.Notice, contents: (setMicStream, renderCurrentStream, hasActiveMicStream) ->
    h 'div', style: {
      display: 'inline-block'
      position: 'relative'
      width: '768px'
      height: '64px'
      border: '1px solid #c0c0c0'
      borderRadius: '3px'
    },
    (
      h 'span', style: {
        padding: '0 10px'
        height: '64px'
        lineHeight: '64px'
      }, 'Input: ' + (if hasActiveMicStream then 'Active' else 'Inactive')
    ),
    (
      (renderCurrentStream (stream, DisplayStatus) ->
        h MicrophoneStreamStatus, stream: stream, contents: (streamIsActive) ->
          streamIsActive and h DisplayStatus, on: true, contents: ->
            h 'button', onClick: (-> stream.getTracks()[0].stop()), 'Stop Listening'
      ) or h MicrophoneRequestButton, onInputStream: ((stream) -> setMicStream stream; onInputStream stream)
    )

module.exports = InputPanel
