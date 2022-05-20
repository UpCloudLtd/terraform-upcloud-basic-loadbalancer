package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const (
	cloudflareAPITokenEnvKey = "CLOUDFLARE_API_TOKEN"
	cloudflareZoneEnvKey     = "TF_VAR_cloudflare_zone_id"
	upcloudUsernameEnvKey    = "UPCLOUD_USERNAME"
	upcloudPasswordEnvKey    = "UPCLOUD_PASSWORD"
)

var requiredEnvVars = []string{
	cloudflareAPITokenEnvKey,
	cloudflareZoneEnvKey,
	upcloudPasswordEnvKey,
	upcloudUsernameEnvKey,
}

func TestBasicLoadBalancer(t *testing.T) {
	for i := 0; i < len(requiredEnvVars); i++ {
		envVar := os.Getenv(requiredEnvVars[i])
		if envVar == "" {
			t.Logf("%s enviroment variable is not set", requiredEnvVars[i])
			t.FailNow()
		}
	}

	subdomain := strings.ToLower(random.UniqueId())

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./basic",
		Vars: map[string]interface{}{
			"subdomain_name": subdomain,
		},
	})

	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	url := terraform.Output(t, opts, "url")
	urlWithFeRule := fmt.Sprintf("%s?test=1", url)

	// The waiting time is fairly long here, as DNS propagation can take quite a bit
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, Test!", 80, 5*time.Second)
	http_helper.HttpGetWithRetry(t, urlWithFeRule, nil, 200, "Returned!", 80, 5*time.Second)
}
