Readable = require('stream').Readable

RMS_THRESHOLD = 0.1
DEBOUNCE_DELAY = 0.1

class FilterThresholdDetector
  constructor: (filterNode) ->
    @_status = false
    @_tripTime = null
    @output = new Readable({ objectMode: true, read: (=>) })

    filterNode.rmsOutput.on 'data', ({ time, value }) =>
      # see if we crossed the threshold in expected direction
      isTripped = if @_status then (value < RMS_THRESHOLD) else (value >= RMS_THRESHOLD)

      if isTripped
        # track time of initial crossing and flip status when sustained for long enough
        if @_tripTime is null
          @_tripTime = time
        else if time >= @_tripTime + DEBOUNCE_DELAY
          @_status = not @_status
          @output.push({ time: time, value: @_status })
      else
        @_tripTime = null

module.exports = FilterThresholdDetector
