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

InputPanel = ({ onInputStream }) ->
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
    }, 'Select Input:'
  ),
  (
    h MicrophoneRequestButton, onInputStream: onInputStream
  )

module.exports = InputPanel
