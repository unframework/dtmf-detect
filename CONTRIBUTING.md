## React Usage Notes

Sparkline component maintains its own timeline data. This is because time-resolution/etc are actually rendering concerns, the model object being rendered is the "time series" as a contained whole.

Smooth transitioning: detector/button trackers are on the outside, but feed tracker components to layout children that then convey target coords back up?
