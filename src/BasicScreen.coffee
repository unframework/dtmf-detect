React = require('react')
D = require('react-dynamics')

Hotkeyable = require('./Hotkeyable.coffee')
StreamValue = require('./StreamValue.coffee')
ToneTester = require('./ToneTester.coffee')

h = React.createElement

TestButton = ({ code, loFrequency, loDetectorValue, hiFrequency, hiDetectorValue, inputNode }) ->
  h D.Pressable, contents: (pressState) =>
    h ToneTester, frequency: loFrequency, inputNode: inputNode, on: pressState, contents: () =>
      h ToneTester, frequency: hiFrequency, inputNode: inputNode, on: pressState, contents: () =>
        h 'button', style: {
          boxSizing: 'border-box'
          display: 'inline-block'
          width: '40px'
          height: '50px'
          padding: '0'
          fontFamily: 'Courier New, mono'
          fontWeight: 'bold'
          fontSize: '24px'
          color: '#808080'
          lineHeight: '48px'
          textAlign: 'center'
          background: (if loDetectorValue and hiDetectorValue then '#c0ffc0' else '#e0e0e0')
          cursor: 'pointer'
          border: '1px solid #c0c0c0'
          borderRadius: '5px'
          boxShadow: (if loDetectorValue and hiDetectorValue then '0px 0px 10px -5px #000 inset' else '')
        }, code

BasicScreen = ({ loBank, hiBank, coder, inputNode, widthPx, heightPx }) ->
  tdStyle = { display: 'table-cell', verticalAlign: 'middle', textAlign: 'center', border: 0, padding: '10px', width: '80px', height: '80px' }

  groupItems = {}
  for loDetector, lo in loBank
    groupItems['lo' + lo] = do(loDetector) -> (cb) -> h StreamValue, stream: loDetector.output, contents: (data) -> cb(data and data.value)
  for hiDetector, hi in hiBank
    groupItems['hi' + hi] = do(hiDetector) -> (cb) -> h StreamValue, stream: hiDetector.output, contents: (data) -> cb(data and data.value)

  h 'div', style: {
    display: 'inline-block'
    position: 'relative'
    width: widthPx + 'px'
    height: heightPx + 'px'
    lineHeight: heightPx + 'px'
    overflow: 'hidden',
    border: '1px solid #c0c0c0'
    borderRadius: '3px'
  }, h D.GroupState, items: groupItems, contents: (detectorStates) -> h 'div', style: {
    display: 'table'
    tableLayout: 'fixed'
    border: 0
    margin: '40px auto'
    padding: 0
    cellSpacing: 0
    lineHeight: '1em'
  }, (
    for loDetector, lo in loBank
      h 'div', key: lo, style: { display: 'table-row' }, (
        for hiDetector, hi in hiBank
          h 'div', key: hi, style: tdStyle,
            h TestButton,
              code: coder.getCode(lo, hi),
              loFrequency: loDetector.rms.frequency,
              loDetectorValue: detectorStates['lo' + lo],
              hiFrequency: hiDetector.rms.frequency,
              hiDetectorValue: detectorStates['hi' + hi],
              inputNode: inputNode
      )
  )

module.exports = BasicScreen
