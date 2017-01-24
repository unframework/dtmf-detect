Readable = require('stream').Readable

RMS_THRESHOLD = 0.1
DEBOUNCE_DELAY = 0.1

class FilterThresholdDetector
  constructor: (rms) ->
    @output = new Readable({ objectMode: true, read: (=>) })
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
        else if time >= @_tripTime + DEBOUNCE_DELAY
          @value = not @value
          @output.push({ time: time, value: @value })
      else
        @_tripTime = null

module.exports = FilterThresholdDetector
