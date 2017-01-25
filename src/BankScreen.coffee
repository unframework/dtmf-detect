React = require('react')

FilterNode = require('./FilterNode.coffee')

h = React.createElement

BankScreen = ({ bankList, keyCodeListSet, inputNode, widthPx, heightPx }) ->
  bankWidthPx = 240
  nodeHeightPx = 50
  captionHeightPx = 20

  h 'div', style: {
    display: 'inline-block'
    position: 'relative'
    width: widthPx + 'px'
    height: heightPx + 'px'
    lineHeight: heightPx + 'px'
    overflow: 'hidden',
    border: '1px solid #c0c0c0'
    borderRadius: '3px'
  }, (
    for bank, bankIndex in bankList
      h 'div', key: bankIndex, style: {
        position: 'relative'
        display: 'inline-block'
        verticalAlign: 'middle'
        width: bankWidthPx + 'px'
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
        }, 'Set ' + bankIndex
        for detector, i in bank
          h 'div', key: i, style: {
            position: 'absolute'
            left: 0
            right: 0
            top: (captionHeightPx + i * nodeHeightPx) + 'px'
            height: nodeHeightPx + 'px'
            lineHeight: nodeHeightPx + 'px'
            textAlign: 'center'
          }, h FilterNode, { thresholdDetector: detector, keyCode: keyCodeListSet[bankIndex][i], inputNode: inputNode }
      ]
  )

module.exports = BankScreen
