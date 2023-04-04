# Examples

The configuration in this directory creates an AWS OpenSearch domain.

This example is designed to be used in the [cloud-platform-environments](https://github.com/ministryofjustice/cloud-platform-environments/) repository.

The proxy URL will be output to a Kubernetes Secret. This is the URL you should use from your namespace's pod to connect to the OpenSearch domain.

## Usage

In the cloud-platform-environments repository, in your namespace path, create a directory called `resources` (if there isn't one already) and refer to the contents of [opensearch.tf](opensearch.tf) to define the module variables.

Make sure to change placeholder values to what is appropriate and refer to the [Cloud Platform user guide on Creating an OpenSearch domain](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/opensearch/create.html) for further details on what these can be set to, including more detailed examples for `production` and `non-production` domains.

The top-level README in this repository also refers to other variables you can set to further customise your resource.

Commit your changes to a branch and raise a pull request. Once approved, you can merge and the changes will be applied. Shortly after, you should be able to access the `Secret` on Kubernetes and access the resources. You might want to refer to the [documentation on Secrets](https://kubernetes.io/docs/concepts/configuration/secret/).
