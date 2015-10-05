Workers represent the smallest unit of work. The worker is the one that
does all the communication work with the server. We use the `unirest` package
as our HTTP Client.

    RestClient = require('unirest')

Workers can be in the following states.

    # Waiting on credentials callback
    NOT_READY = 'NOT_READY'
    # Ready to work
    READY = 'READY'

Workers need to know their parent probe to pull all the configuration values.

    module.exports = class Worker

      constructor: (@probe, @_id) ->
        @url     = "#{@probe.HOST}#{@probe.config.endpoint}"
        @method  = @probe.config.endpointMethod
        @verbose = @probe.config.verbose
        @_getCredentials @probe.credentials
        @_status = READY
        @emitter = new (require('events').EventEmitter)()

As with the `Probeshifter` class, you can instantiate a worker by the normal
`new Worker()` syntax or the ruby-like syntax `Worker.new()`

      this.new = (probe) ->
        new Worker probe

*Something about the credentials factory*

      _getCredentials: (factory) ->
        return unless factory and typeof factory if 'function'
        setCredentials = (headers) =>
            @credentialHeaders = headers
            @_status = READY
            @start()
        @credentialHeaders = factory(setCredentials)
        @_status = NOT_READY unless @credentialHeaders

The `start` function is where the HTTP call is made. The worker will not fire the
request unless it's `READY` to do so, though.

      start: ->
        return unless @_status is READY
        console.log "Worker #{@probe.config.description}:#{@_id} hitting #{@method} - #{@url}" if @verbose
        req = RestClient  @method, @url
All request are assumed to be made in JSON format.

        req.header 'Content-Type': 'application/json'
Authentication headers are added to the HTTP request if present.

        req.header @credentialHeaders if @credentialHeaders

Data is fetched from the probe.

        req.send @probe.data if typeof @probe.data is 'object'
        req.send @probe.data() if typeof @probe.data is 'function'

Request response is then handle by the `handleResponse` function.

        req.end @handleResponse

      handleResponse: (response) =>
        if response.error
          @handleError response.error
          return

        @emitter.emit 'end', response

If the request wasn't successful, the worker will throw exceptions according to
the type of error recieved from the server.

      handleError: (err) ->
        @emitter.emit 'error', err
        # throw 'Couldn\'t reach host.' if err.code is 'ECONNREFUSED'
        # throw 'Service requires authentication' if err.status is 401
        # throw 'Unknown error: ' + err

      on: (event, listener) ->
        @emitter.on event, listener
