React = require('react')

Bank = require('./Bank.coffee')

h = React.createElement

BankScreen = ({ bankList, testInputNode, widthPx, heightPx }) ->
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
      h Bank, label: 'Set ' + bankIndex, bank: bank, testInputNode: testInputNode
  )

module.exports = BankScreen
