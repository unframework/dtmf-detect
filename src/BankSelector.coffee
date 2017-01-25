EventEmitter = require('events').EventEmitter

class BankSelector
  constructor: (bank) ->
    @range = bank.length
    @value = null
    @output = new EventEmitter()

    @_status = (detector.value for detector in bank)
    @_recomputeValue()

    for detector, i in bank
      detector.output.on 'data', @_onData.bind(this, i)

  _recomputeValue: ->
    # exclusive OR
    sum = 0
    index = null
    for value, i in @_status
      if value
        index = i
        sum += 1

    @value = if sum is 1 then index else null

  _onData: (i, { time, value }) ->
    oldValue = @value

    @_status[i] = value
    @_recomputeValue()

    if oldValue isnt @value
      @output.emit 'data', { time: time, value: @value }

module.exports = BankSelector
