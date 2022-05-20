# Basic example

A simple example with 3 servers and a load balancer that distributes the traffic between them. The example assumes that each of the servers has some application listening on port 3000.

Once you deploy it, go to your domain settings and add a CNAME record that points to the `lb_url` output variable. After the change gets propagated, all the traffic to your domain (`my.domain.com` in this example) will be distributed among the 3 servers.
