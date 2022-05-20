# UpCloud Basic Loadbalancer Tests

For the purposes of testing this module we use Go language with Terratest library. Most of the actual setup and teardown is actually performed by Terraform (via Terratest).
Since this module sets up SSL certificate for the user, we need some additional DNS setup to properly test the whole thing, and we use Cloudflare for that. The most basic test works as follows:

1. Create multiple servers that listen on port 3000 and respond with simple string (with UpCloud provider)
2. Create loadbalancer (using this module, with UpCloud provider)
3. Create a CNAME DNS record that points towards load balancer server (with Cloudflare provider). For that you need to have a preexisting Zone (domain) in Cloudlfare and pass its ID via TF input variables. The subdomain will be an automatically generated unique (sort of) string. The full URL (subdomain + domain) will be saved as TF output.
4. Verify that the servers are reachable via the saved URL with HTTP GET request. This might take a while as we need to wait for DNS to propagate.

## Running tests locally
First, in order to run the test you will need a Cloudflare account, with at least one Zone (domain) registered there. Once that is done, create a new API token that has permissions to add records for that one Zone.

Next, set the following environment variables:
* `UPCLOUD_USERNAME` - username for your UpCloud account
* `UPCLOUD_PASSWORD` - password for your UpCloud account
* `CLOUDFLARE_API_TOKEN` - the cloudflare API token that you have just created
* `TF_VAR_cloudflare_zone_id` - ID of the Cloudflare Zone (tests will setup some DNS record for it)

Now run `cd test && go test` and give it a few minutes.
