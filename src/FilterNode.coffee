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
      verticalAlign: 'middle'
      width: '145px'
      height: '40px'
    }, [
      h 'div', style: {
        boxSizing: 'border-box'
        position: 'absolute'
        top: '0px'
        right: '0px'
        padding: '5px'
        width: '60px'
        height: '40px'
        background: '#c0c0c0'
        borderRadius: '5px'
      }, h Sparkline, { detectorRMSNode: @_detectorRMSNode, bufferSize: 10 }

      h 'span', style: {
        position: 'absolute'
        top: '0px'
        left: '0px'
        fontFamily: 'Courier New, mono'
        fontWeight: 'bold'
        color: '#808080'
        width: '80px'
        lineHeight: '38px'
        textAlign: 'center'
        border: '1px solid #c0c0c0'
        borderRadius: '5px'
      }, @_detectorRMSNode.frequency + 'Hz'
    ]

module.exports = FilterNode
