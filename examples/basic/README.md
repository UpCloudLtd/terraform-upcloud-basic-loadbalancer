# Basic example

A simple example with 3 servers and a load balancer that distributes the traffic between them. The example uses an user-data script to launch a HTTP server listening to port 80 on each server. The example does not enable TLS on frontend by default.

## Getting started

To deploy private network, three servers, and load balancer on your UpCloud account, run:

```bash
terraform init
terraform apply
```

Once the deployment is complete and load balancer has reached `running` state you can use `curl` or your browser to send request to the load balancer available in the URL defined by `lb_url` output variable:

```bash
curl $(terraform output -raw lb_url)
```

Note that it might take some time for the DNS name to propagate. During this time the above `curl` command will likely fail with `Could not resolve host: ...` error message.

The output should include hostname of the backend server, for example:

```txt
Hello from lb-module-basic-example-server-1
```

## Enable TLS

The example does not enable TLS on frontend by default. To enable TLS, uncomment `domains` variable in [main.tf](./main.tf) and replace example domain with your domain. Change also the value for `frontend_port` from `80` to `443`.

Deploy the changes with `terraform apply`. When the deployment is completed, go to your domain settings and add a CNAME record that points to the `lb_url` output variable. After the change gets propagated, all the traffic to your domain will be distributed among the 3 servers.
