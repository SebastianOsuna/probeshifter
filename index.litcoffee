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

      workers: 10

Optionally, add a description

      description: 'Request a new trip'

Or make the probe verbose (it'll log everything)

      verbose: true

Now, it's time to initialize our probe

    probe = Probeshifter.new config

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



## Why credential factories?

1. You might want that each of your probe's worker represent a different user.
With a factory, you can return different credentials upon each sucesive call.
