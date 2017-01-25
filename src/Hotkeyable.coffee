React = require('react')

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

module.exports = Hotkeyable
