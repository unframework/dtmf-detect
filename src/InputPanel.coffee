React = require('react')
ReactDOM = require('react-dom')
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

# inspired by https://github.com/kylestetz/AudioDrop/blob/master/AudioDrop.js
class FileDropTarget extends React.PureComponent
  constructor: ->
    super()

    @state = { dragStack: 0 }

    @_enterListener = @_onDragChange.bind(this, true)
    @_leaveListener = @_onDragChange.bind(this, false)
    @_overListener = @_onDragOver.bind(this)
    @_dropListener = @_onDrop.bind(this)

  _onDragChange: (isEntering, e) ->
    e.stopPropagation()
    if isEntering then e.preventDefault() # helps signal a valid target

    @setState (state) -> { dragStack: state.dragStack + (if isEntering then 1 else -1) }

  _onDragOver: (e) ->
    e.stopPropagation()
    e.preventDefault() # helps signal a valid target

  _onDrop: (e) ->
    e.stopPropagation()
    e.preventDefault()

    for file in Array.prototype.slice.call(e.dataTransfer.files) when file.type.indexOf('audio') isnt -1
      @props.onDrop file

    @setState { dragStack: 0 } # no dragleave event will happen

  componentDidMount: ->
    dom = ReactDOM.findDOMNode(this)

    dom.addEventListener 'dragenter', @_enterListener, false
    dom.addEventListener 'dragleave', @_leaveListener, false
    dom.addEventListener 'dragover', @_overListener, false
    dom.addEventListener 'drop', @_dropListener, false

  componentWillUnmount: ->
    dom = ReactDOM.findDOMNode(this)

    dom.removeEventListener 'dragenter', @_enterListener
    dom.removeEventListener 'dragleave', @_leaveListener
    dom.removeEventListener 'dragover', @_overListener
    dom.removeEventListener 'drop', @_dropListener

  render: ->
    @props.contents(@state.dragStack > 0)

hookupMicStream = (stream, inputNode) ->
  sourceNode = context.createMediaStreamSource(stream)
  sourceNode.connect inputNode

  stream.getTracks()[0].addEventListener 'ended', ->
    sourceNode.disconnect()

InputPanel = ({ inputNode }) ->
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
        display: 'inline-block'
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
      ) or h MicrophoneRequestButton, onInputStream: ((stream) -> setMicStream stream; hookupMicStream stream)
    ),
    (
      h FileDropTarget, onDrop: ((file) -> console.log file), contents: (dropActive) -> h 'span', style: {
        display: 'inline-block'
        padding: '0 10px'
        height: '64px'
        lineHeight: '64px'
        background: (if dropActive then '#f0f0f0' else '')
      }, '[Drop Audio File Here]'
    )

module.exports = InputPanel
