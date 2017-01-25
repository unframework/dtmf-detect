EventEmitter = require('events').EventEmitter

RMS_THRESHOLD = 0.01
DEBOUNCE_DELAY_ON = 0.005 # quick switch-on
DEBOUNCE_DELAY_OFF = 0.01 # slow switch-off

class FilterThresholdDetector
  constructor: (rms) ->
    @output = new EventEmitter()
    @rms = rms
    @value = false

    @_tripTime = null

    rms.output.on 'data', ({ time, value }) =>
      # see if we crossed the threshold in expected direction
      isTripped = if @value then (value < RMS_THRESHOLD) else (value >= RMS_THRESHOLD)

      if isTripped
        # track time of initial crossing and flip status when sustained for long enough
        if @_tripTime is null
          @_tripTime = time
        else if time >= @_tripTime + (if @value then DEBOUNCE_DELAY_OFF else DEBOUNCE_DELAY_ON)
          @value = not @value
          @output.emit('data', { time: time, value: @value })
      else
        @_tripTime = null

module.exports = FilterThresholdDetector
