React = require('react')

class Collector extends React.PureComponent
  constructor: (props) ->
    super()

    # @todo handle errors for addItem/etc
    propName = props.property
    addItem = @_addItem.bind(this)
    removeItem = @_removeItem.bind(this)

    @_collectorComponent = class Collector extends React.PureComponent
      constructor: () ->
        super()

      componentWillMount: ->
        if @props[propName]
          addItem @props[propName]

      componentWillReceiveProps: (nextProps) ->
        if @props[propName] isnt nextProps[propName]
          if @props[propName]
            removeItem @props[propName]

          if nextProps[propName]
            addItem nextProps[propName]

      componentWillUnmount: ->
        if @props[propName]
          removeItem @props[propName]

      render: ->
        @props.contents @props[propName]

  _addItem: (item) ->
    @props.onAdd item

  _removeItem: (item) ->
    @props.onRemove item

  render: ->
    @props.contents @_collectorComponent

module.exports = Collector
