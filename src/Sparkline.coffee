React = require('react')

h = React.createElement
LINE_BG = 'url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1IiBoZWlnaHQ9IjUiPgo8cmVjdCB3aWR0aD0iMyIgaGVpZ2h0PSIzIiBmaWxsPSIjODA4MDgwIj48L3JlY3Q+Cjwvc3ZnPg==") 0 100%'

RMS_GAIN = 4

class Sparkline extends React.PureComponent
  constructor: (props) ->
    super()

    @_detectorRMSNode = props.detectorRMSNode
    @_series = (0 for [ 0 ... props.bufferSize ])
    @_unmounted = false

  _processFrame: ->
    @_series.shift()
    @_series.push(RMS_GAIN * @_detectorRMSNode.rmsValue)

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
    graphUnitPx = 5
    resolution = 5
    heightPx = (resolution + 1) * graphUnitPx
    graphWidthPx = @_series.length * graphUnitPx

    h 'div', style: {
      position: 'relative'
      display: 'inline-block'
      width: graphWidthPx + 'px'
      height: heightPx + 'px'
      background: '#eee'
    }, (
      for v, i in @_series
        iv = Math.max(0, Math.min(resolution, Math.round(v * resolution)))

        h 'span', key: i, style: {
          boxSizing: 'content-box'
          position: 'absolute'
          left: (1 + i * graphUnitPx) + 'px'
          bottom: '-1px'
          width: (graphUnitPx - 2) + 'px'
          height: iv * graphUnitPx + 2 + 'px'
          background: LINE_BG
          borderTop: (graphUnitPx - 2) + 'px solid #444'
        }
    )

module.exports = Sparkline
