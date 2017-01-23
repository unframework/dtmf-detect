React = require('react')

FilterNode = require('./FilterNode.coffee')

Bank = ({ label, bank }) ->
  h = React.createElement
  widthPx = 100
  nodeHeightPx = 40
  captionHeightPx = 20

  h 'div', style: {
    position: 'relative'
    display: 'inline-block'
    width: widthPx + 'px'
    height: (captionHeightPx + bank.length * nodeHeightPx) + 'px'
  }, [
    h 'div', key: -1, style: {
      position: 'absolute'
      left: 0
      right: 0
      top: 0
      height: captionHeightPx + 'px'
      lineHeight: captionHeightPx + 'px'
      textAlign: 'center'
    }, label
    for detector, i in bank
      h 'div', key: i, style: {
        position: 'absolute'
        left: 0
        right: 0
        top: (captionHeightPx + i * nodeHeightPx) + 'px'
        height: nodeHeightPx + 'px'
        lineHeight: nodeHeightPx + 'px'
        textAlign: 'center'
      }, h FilterNode, { detectorRMSNode: detector }
  ]

module.exports = Bank
