React = require('react')

class Sparkline extends React.PureComponent
  constructor: (props) ->
    super()

    @_detectorRMSNode = props.detectorRMSNode
    @_series = (0 for [ 0 ... 10 ])
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
    h = React.createElement
    resolution = 10
    graphUnitPx = 3
    heightPx = (resolution + 1) * graphUnitPx
    graphWidthPx = @_series.length * graphUnitPx
    textWidthPx = 60

    h 'div', style: {
      boxSizing: 'border-box'
      position: 'relative'
      display: 'inline-block'
      paddingLeft: graphWidthPx + 'px'
      width: (graphWidthPx + textWidthPx) + 'px'
      height: heightPx + 'px'
      background: '#f8f8f8'
      textAlign: 'center'
      lineHeight: heightPx + 'px'
    }, [
      h 'div', key: -1, style: {
        position: 'absolute'
        left: 0
        top: 0
        width: graphWidthPx + 'px'
        height: heightPx + 'px'
        background: '#eee'
      }
      for v, i in @_series
        iv = Math.max(0, Math.min(resolution, Math.round(v * resolution)))
        h 'span', { key: i, style: {
          boxSizing: 'border-box'
          position: 'absolute'
          left: i * graphUnitPx + 'px'
          bottom: 0
          width: graphUnitPx + 'px'
          height: (iv + 1) * graphUnitPx + 'px'
          background: '#666'
          borderTop: '2px solid #444'
          transition: 'height 0.1s'
        } }, ''
      @_detectorRMSNode.frequency + 'Hz'
    ]

module.exports = Sparkline
