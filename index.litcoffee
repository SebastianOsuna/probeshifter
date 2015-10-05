Require the library

    Probeshifter = require './libs/probeshifter'

Define your host

    Probeshifter.HOST = 'http://localhost:3000'

Then define the tasks `config` object for the service you want to test.

    config =

Set the service endpoint and method

      endpoint: '/user/trip'
      endpointMethod: 'POST'

Define how many workers you want running concurrently

      workers: 1

Optionally, add a description

      description: 'Request a new trip'

Or make the probe verbose (it'll log everything)

      verbose: true

### config object
    ###
    config =
      endpoint
      endpointMethod
      workers
      description
      verbose
    ###

Now, it's time to initialize our probe

    probe = Probeshifter.new config

## Sending data

Usually, services require some parameters to work, and more often than not you want
to test how your API behaves with different parameters. To define the parameters
that Probeshifter will send to you API, use the `data` property.

    probe.data = { value1: 'val', value2: 2 }

Or give it a function to generate different for each worker.

    probe.data = ->
      start_address: 'Carrera 15 # 80 - 90'
      start_location_lat: 4.66735
      start_location_lot: -74.0567

## Authentication

For services that require authentication, you can provide your probes with
credential factories. This factories should return an object with Header:Value
pairs that should be used in the HTTP request.

    credentialsFactory = ->
      { Authorization: 'Bearer ca689b206a7a51aadee4534a282043da5527acb7' }

    probe.credentials = credentialsFactory

You can also use async credentials factories. Just make sure it returns a falsy value

    asyncCredentialFactory = (setCredentials) ->
      setTimeout ->
        setCredentials { Authorization: 'Bearer ' }
      , 1000
      return null

Now, you can run your probe

    probe.run()

## Handling results

After the probe finish running, it will emit an `'end'` event so you can handle
the data gathered by the workers. The listener function should expect a array of
objects. This array has as many objects as workers in the probe.

    probe.on 'end', (results) ->
      console.log 'Probe finished with this many workers: ', results.length

Each object in this array may have either an `error` or a `data` property.

      console.log 'data: ',results[0].data
      #=> null | response from the http call
      console.log 'error: ', results[0].error
      #=> error | http error

## Why credential factories?

1. You might want that each of your probe's worker represent a different user.
With a factory, you can return different credentials upon each sucesive call.
