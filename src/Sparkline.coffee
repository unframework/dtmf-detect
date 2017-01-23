React = require('react')

h = React.createElement

class Sparkline extends React.PureComponent
  constructor: (props) ->
    super()

    @_detectorRMSNode = props.detectorRMSNode
    @_series = (0 for [ 0 ... props.bufferSize ])
    @_unmounted = false

  _processFrame: ->
    @_series.shift()
    @_series.push(4 * @_detectorRMSNode.rmsValue)

  componentDidMount: ->
    intervalId = setInterval =>
      if @_unmounted
        clearInterval intervalId
      else
        @_processFrame()
        @forceUpdate()
    , 100

  componentWillUnmount: ->
    @_unmounted = true

  render: ->
    heightPx = this.props.heightPx
    graphUnitPx = this.props.bufferUnitPx

    resolution = heightPx - 2
    graphWidthPx = @_series.length * graphUnitPx

    h 'div', style: {
      position: 'absolute'
      left: 0
      top: 0
      width: graphWidthPx + 'px'
      height: heightPx + 'px'
      background: '#eee'
    }, (
      for v, i in @_series
        iv = Math.max(0, Math.min(resolution, Math.round(v * resolution)))

        h 'span', { key: i, style: {
          boxSizing: 'content-box'
          position: 'absolute'
          left: i * graphUnitPx + 'px'
          bottom: 0
          width: graphUnitPx + 'px'
          height: iv + 'px'
          background: '#666'
          borderTop: '2px solid #444'
          transition: 'height 0.1s'
        } }, ''
    )

module.exports = Sparkline
