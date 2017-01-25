React = require('react')
D = require('react-dynamics')

Hotkeyable = require('./Hotkeyable.coffee')
StreamValue = require('./StreamValue.coffee')
ToneTester = require('./ToneTester.coffee')
Sparkline = require('./Sparkline.coffee')

h = React.createElement

FilterNode = ({ keyCode, thresholdDetector, inputNode }) ->
  h 'div', style: {
    position: 'relative'
    display: 'inline-block'
    verticalAlign: 'middle'
    width: '195px'
    height: '40px'
  }, (
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
    }, h Sparkline, { detectorRMS: thresholdDetector.rms, bufferSize: 10 }
  ),

  (
    h StreamValue, stream: thresholdDetector.output, contents: (data) => h 'span', style: {
      position: 'absolute'
      top: '0px'
      left: '45px'
      fontFamily: 'Courier New, mono'
      fontWeight: 'bold'
      color: '#808080'
      width: '80px'
      lineHeight: '38px'
      textAlign: 'center'
      border: '1px solid #c0c0c0'
      background: if data and data.value then '#e0ffe0' else '#fff'
      borderRadius: '5px'
    }, thresholdDetector.rms.frequency + 'Hz'
  ),

  (
    h Hotkeyable, keyCode: keyCode, contents: (keyState) => h D.Pressable, contents: (pressState) =>
      h ToneTester, frequency: thresholdDetector.rms.frequency, inputNode: inputNode, on: keyState or pressState, contents: (testerState) =>
        h 'button', style: {
          boxSizing: 'border-box'
          position: 'absolute'
          top: '50%'
          left: '0px'
          marginTop: '-15px'
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
  )

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
