# In-browser DTMF Detection Demo

Using WebAudio to detect DTMF codes (touch-tone phone keys). Live demo here: https://unframework.github.io/dtmf-detect/

## References

- https://en.wikipedia.org/wiki/Dual-tone_multi-frequency_signaling
- http://dsp.stackexchange.com/questions/15594/how-can-i-reduce-noise-errors-when-detecting-dtmf-with-the-goertzel-algorithm#comment26780_15594
- https://github.com/mmckegg/audio-rms
- https://github.com/antoinet/webaudio/blob/master/dtmf-demod.html (original FFT approach which did not pan out)
- http://jetcityorange.com/dtmf/


Concept hierarchy for affordances (which might be more like traits - any state object has-a affordance):

- Affordance
    - ScreenAffordance
    - LineAffordance (CLI)

Affordances are pretty much like r/o JSON stuff read during render time? However, actual render layer still needs its own state (just listen to upstream stuff and keep own stuff too)
