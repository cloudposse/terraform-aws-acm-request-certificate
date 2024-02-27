package test

import (
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-west-1.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}
	// Keep the output quiet
	if !testing.Verbose() {
		terraformOptions.Logger = logger.Discard
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	if _, err := terraform.InitAndApplyE(t, terraformOptions); err != nil {
		require.FailNow(t, "Terraform \"apply\" failed, skipping the rest of the tests")
	}

	// Run `terraform output` to get the value of an output variable
	zoneName := terraform.Output(t, terraformOptions, "zone_name")

	expectedZoneName := "test-zone-2.testing.cloudposse.co"
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedZoneName, zoneName)

	// Run `terraform output` to get the value of an output variable
	certificateArn := terraform.Output(t, terraformOptions, "certificate_arn")

	// Verify we're getting back the outputs we expect
	assert.Contains(t, certificateArn, "arn:aws:acm:us-west-1:126450723953:certificate/")
}

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-west-1.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"enabled":    "false",
		},
	}
	// Keep the output quiet
	if !testing.Verbose() {
		terraformOptions.Logger = logger.Discard
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Get all the output and lookup a field. Pass if the field is missing or empty.
	// Get all the output and lookup a field. Pass if the field is missing or empty.
	allOutputs := terraform.OutputAll(t, terraformOptions)

	// Verify we're getting back the outputs we expect
	assert.Empty(t, allOutputs["id"], "When disabled, 'id' output should be empty.")
	assert.Empty(t, allOutputs["arn"], "When disabled, 'arn' output should be empty.")
	assert.Empty(t, allOutputs["domain_validation_options"], "When disabled, 'domain_validation_options' output should be empty.")
	assert.Empty(t, allOutputs["validation_id"], "When disabled, 'validation_id' output should be empty.")
	assert.Empty(t, allOutputs["validation_certificate_arn"], "When disabled, 'validation_certificate_arn' output should be empty.")
	assert.Empty(t, allOutputs["parent_zone_id"], "When disabled, 'parent_zone_id' output should be empty.")
	assert.Empty(t, allOutputs["parent_zone_name"], "When disabled, 'parent_zone_name' output should be empty.")
	assert.Empty(t, allOutputs["zone_id"], "When disabled, 'zone_id' output should be empty.")
	assert.Empty(t, allOutputs["zone_name"], "When disabled, 'zone_name' output should be empty.")
	assert.Empty(t, allOutputs["zone_fqdn"], "When disabled, 'zone_fqdn' output should be empty.")
	assert.Empty(t, allOutputs["certificate_id"], "When disabled, 'certificate_id' output should be empty.")
	assert.Empty(t, allOutputs["certificate_arn"], "When disabled, 'certificate_arn' output should be empty.")
	assert.Empty(t, allOutputs["certificate_domain_validation_options"], "When disabled, 'certificate_domain_validation_options' output should be empty.")
	assert.Empty(t, allOutputs["validation_certificate_arn"], "When disabled, 'validation_certificate_arn' output should be empty.")
}
