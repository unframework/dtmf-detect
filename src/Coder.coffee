Readable = require('stream').Readable

class Coder
  constructor: (loSelector, hiSelector, lookupTable) ->
    @value = null
    @output = new Readable({ objectMode: true, read: (=>) })

    @_lookupTable = lookupTable
    @_lo = loSelector
    @_hi = hiSelector

    loSelector.output.on 'data', ({ time }) => @_processChange(time)
    hiSelector.output.on 'data', ({ time }) => @_processChange(time)

  _recomputeValue: ->
    @value = (
      if @_lo.value isnt null and @_hi.value isnt null
        @_lookupTable[@_hi.value * @_lo.range + @_lo.value]
      else
        null
    )

  _processChange: (time) ->
    @_recomputeValue()

    if @value isnt null
      @output.push { time: time, value: @value }

module.exports = Coder
