React = require('react')

Sparkline = require('./Sparkline.coffee')

h = React.createElement

class FilterNode extends React.PureComponent
  constructor: (props) ->
    super()

    @_detectorRMSNode = props.detectorRMSNode

  render: ->
    h 'div', style: {
      position: 'relative'
      display: 'inline-block'
      height: '30px'
      lineHeight: '30px'
      verticalAlign: 'middle'
      paddingLeft: '30px'
      width: '60px'
      textAlign: 'center'
    }, [
      h Sparkline, { detectorRMSNode: @_detectorRMSNode, bufferSize: 10, bufferUnitPx: 3, heightPx: 30 }

      @_detectorRMSNode.frequency + 'Hz'
    ]

module.exports = FilterNode
