React = require('react')

FilterNode = require('./FilterNode.coffee')

Bank = ({ label, bank, testInputNode }) ->
  h = React.createElement
  widthPx = 210
  nodeHeightPx = 50
  captionHeightPx = 20

  h 'div', style: {
    position: 'relative'
    display: 'inline-block'
    verticalAlign: 'middle'
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
      fontFamily: 'Courier New, mono'
      fontWeight: 'bold'
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
      }, h FilterNode, { detectorRMSNode: detector, testInputNode: testInputNode }
  ]

module.exports = Bank
