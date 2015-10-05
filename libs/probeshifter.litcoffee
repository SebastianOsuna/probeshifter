    Worker = require './worker'
    EventEmitter = require('events').EventEmitter
This is the base class of the Probeshifer library

    module.exports = class Probeshifter extends EventEmitter


All probes inherit the host address from global `HOST` property

      this.HOST = 'http://localhost'

When instantiating a probe, you must provide a configuration object. The `endpoint`
property in this object is **required**.

      constructor: (@config) ->
        throw 'You must provide a configuration object' if !@config
        throw 'You must provide an endpoint to test' if !@config.endpoint
The `endpointMethod` configuration variable is *optional* and defaults to `GET`.
Other options are `POST`, `PUT`, `DELETE`.

        @config.endpointMethod ||= 'GET'
        throw 'Invalid endpointMethod' if ['GET', 'POST', 'PUT', 'DELETE'].indexOf(@config.endpointMethod.toUpperCase()) is -1
The number of `workers` the probe will run defaults to `1`.

        @config.workers        ||= 1
Also, by default, the probe will not log anything, so `verbose = false`.

        @config.verbose        ||= false
All probes have an internal list of workers and it's onw `HOST` property in case
you want to redefine it. Also a counter of how many workers have finished.

        # Initialize properties
        @_workers = []
        @_results = []
        @_finishedWorkers = 0
        # Define probe host
        @HOST = Probeshifter.HOST

You can also include a `description` property in the config object. This description
will be used while logging so you can keep track of your probe's activity.

        @config.description    ||= '$'
        console.log "Probe '#{@config.description}' created." if @config.verbose

You can initialize a new probe by the usual `new Probeshifter()` syntax or a more
rubist syntax; `Probeshifter.new()`

      this.new = (config) ->
        new Probeshifter config

All the magic happens here, at the `run` function. The probe initializes all workers
and puts them to work.

      run: ->
        # Create workers
        console.log "Probe '#{@config.description}' running..." if @config.verbose
        [0...@config.workers].forEach (n) =>
          @_workers.push(w = Worker.new this, n)
          @_results.push {}
          # Start worker
          console.log "Worker '#{@config.description}':#{n} started." if @config.verbose
          w.start()

When each worker is done, it will call the `gatherResults` or `gatherErrors` listeners
to handle the result/errors of each worker.

          # Bind event listeners
          w.on 'end', @gatherResults.bind(this, n)
          w.on 'error', @gatherErrors.bind(this, n)

## Handling workers results


      gatherResults: (workerId, response) =>
        @_finishedWorkers++
        console.log "Worker '#{@config.description}':#{workerId} done." if @config.verbose
        @_results[workerId].data = response.body
        # All workers are done
        this.emit 'end', @_results if @_finishedWorkers is @config.workers

      gatherErrors: (workerId, error) =>
        @_finishedWorkers++
        console.log "Worker '#{@config.description}':#{workerId} done with errors." if @config.verbose
        @_results[workerId].error = error
        # All workers are done
        this.emit 'end', @_results if @_finishedWorkers is @config.workers
