# Distributed
An example of running multiple instances locally, using nginx as a load balancer, and communicating between then with nats.

## Setup and Usage
Using go 1.10+, run `dep ensure` to grab dependencies.

#### Start nats
1. `./nats.sh start`

#### Start nginx
1. `./nginx start`
2. `./nginx copy`

#### Start instances
Currently, nginx conf is configured to use 2 upstream apps - port: 9051 and 9052.
Open 2 terminals and run:
- `PORT=9051 ./distributed`
and 
- `PORT=9052 ./distributed`
Can also do `PORT=xxxx bra run` if have bra installed.

You can verify everything worked by `curl localhost:9030` to hit the nginx which should then reverse proxy one of the upstream apps.

To add/remove servers, update `ws.conf`.