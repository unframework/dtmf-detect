React = require('react')
D = require('react-dynamics')

Hotkeyable = require('./Hotkeyable.coffee')
ToneTester = require('./ToneTester.coffee')

h = React.createElement

TestButton = ({ keyCode, frequency, inputNode }) ->
  h Hotkeyable, keyCode: keyCode, contents: (keyState) => h D.Pressable, contents: (pressState) =>
    h ToneTester, frequency: frequency, inputNode: inputNode, on: keyState or pressState, contents: (testerState) =>
      h 'button', style: {
        boxSizing: 'border-box'
        display: 'inline-block'
        width: '40px'
        height: '30px'
        padding: '0'
        fontFamily: 'Courier New, mono'
        fontWeight: 'bold'
        fontSize: '12px'
        color: '#808080'
        lineHeight: '28px'
        textAlign: 'center'
        background: (if testerState then '#f8e8e0' else '#e0e0e0')
        cursor: 'pointer'
        border: '1px solid #c0c0c0'
        borderRadius: '5px'
        boxShadow: (if testerState then '0px 0px 10px -5px #000 inset' else '')
      }, 'TEST'

GridScreen = ({ loBank, hiBank, keyCodeListSet, coder, inputNode, widthPx, heightPx }) ->
  bankWidthPx = 240
  nodeHeightPx = 50
  captionHeightPx = 20
  tdStyle = { display: 'table-cell', verticalAlign: 'middle', textAlign: 'center', border: 0, padding: '10px', width: '120px', height: '60px' }

  h 'div', style: {
    display: 'inline-block'
    position: 'relative'
    width: widthPx + 'px'
    height: heightPx + 'px'
    lineHeight: heightPx + 'px'
    overflow: 'hidden',
    border: '1px solid #c0c0c0'
    borderRadius: '3px'
  }, h 'div', style: {
    display: 'table'
    tableLayout: 'fixed'
    border: 0
    margin: '40px auto'
    padding: 0
    cellSpacing: 0
    lineHeight: '1em'
  }, (
    h 'div', style: { display: 'table-row' }, (
      h 'div', style: tdStyle, ''
    ), (
      for hiDetector, hi in hiBank
        h 'div', key: hi, style: tdStyle, hiDetector.rms.frequency + 'Hz', (h 'br'),
          h TestButton, keyCode: keyCodeListSet[1][hi], frequency: hiDetector.rms.frequency, inputNode: inputNode
    )
  ), (
    for loDetector, lo in loBank
      h 'div', key: lo, style: { display: 'table-row' }, (
        h 'div', style: tdStyle, loDetector.rms.frequency + 'Hz ',
          h TestButton, keyCode: keyCodeListSet[0][lo], frequency: loDetector.rms.frequency, inputNode: inputNode
      ), (
        for hiDetector, hi in hiBank
          h 'div', key: hi, style: tdStyle, coder.getCode(lo, hi)
      )
  )

module.exports = GridScreen
