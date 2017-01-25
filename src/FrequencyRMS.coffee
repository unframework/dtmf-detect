EventEmitter = require('events').EventEmitter

# @todo use RxJS instead of streams? marries nicely to React display then
# @todo this has a super long decay for some reason!
class FrequencyRMS
  constructor: (context, freq) ->
    freqFilter = context.createBiquadFilter()
    freqFilter.channelCount = 1
    freqFilter.type = 'bandpass'
    freqFilter.Q.value = 300 # seems small enough of a band for given range
    freqFilter.frequency.value = freq

    sampleCount = 0

    # saving ref on object to avoid garbage collection on mobile
    # using a low buffer size for better latency
    @_rmsComputer = context.createScriptProcessor(256, 1, 1)
    @_rmsComputer.onaudioprocess = (e) =>
      channelData = e.inputBuffer.getChannelData(0)

      sum = 0
      for x in channelData
        sum += x * x

      sampleCount += channelData.length

      @rmsValue = Math.sqrt(sum / channelData.length)
      @output.emit('data', { time: sampleCount / context.sampleRate, value: @rmsValue })

    freqFilter.connect @_rmsComputer
    @_rmsComputer.connect context.destination

    @frequency = freq
    @audioNode = freqFilter
    @rmsValue = 0

    @output = new EventEmitter()

module.exports = FrequencyRMS
