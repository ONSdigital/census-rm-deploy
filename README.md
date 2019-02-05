# census-rm-deploy
Response Management deployment pipelines and documentation

## Pipelines
### CI Kubernetes Pipeline
Specified in `pipelines/ci-kubernetes-pipeline.yml`, this pipeline pulls from the `census-rm-kubernetes` repo triggered by commits to master and applies the latest microservice and handler configs to the kubernetes cluster specified by the pipeline configuration.

#### How to fly
Create a secrets YAML file containing the required configuration:

| Variable | Format | Description |
| --- | --- | ---: |
| kubernetes-server | https://\<host>:\<port> | The URL of the kubernetes server endpoint |
| kubernetes-namespace | String | The kubernetes namespace for concourse to deploy to |
| kubernetes-token | JWT String | A JWT access token. Must be for an account with the required roles in kubernetes |
| kubernetes-certificate-authority | \|  <br>-----BEGIN CERTIFICATE----- <br>\<certificate> <br>-----END CERTIFICATE----- | The certificate authority for the kubernetes cluster |
| github-private-key | \| <br>-----BEGIN PRIVATE KEY----- <br>\<private key> <br>-----END PRIVATE KEY----- | A private SSH key for github with permissions to clone private repositories | 

Then run the fly command:
```bash
fly -t <target> set-pipeline -p <pipeline-name> -c pipelines/ci-kubernetes-pipeline.yml -l <path-to-secrets-yml>
```
This should give you a diff view of the proposed pipeline changes, check the changes and accept if they are correct.

### CI Latest Patch Pipeline
Specified in `pipelines/ci-latest-patch-pipeline.yml`, this pipeline is triggered by new builds for the `latest` tag for the RM container registry images. On being triggered by a new build, it runs a `kubectl patch` for the newly built images deployment updating a timestamp label. This causes kubernetes to re-pull the latest image and bring up new pods since we set `imagePullPolicy: Always` on all deployments.

#### How to fly
Create a secrets YAML file containing the required configuration:

| Variable | Format | Description |
| --- | --- | ---: |
| kubernetes-server | https://\<host>:\<port> | The URL of the kubernetes server endpoint |
| kubernetes-namespace | String | The kubernetes namespace for concourse to deploy to |
| kubernetes-token | JWT String | A JWT access token. Must be for an account with the required roles in kubernetes |
| kubernetes-certificate-authority | \|  <br>-----BEGIN CERTIFICATE----- <br>\<certificate> <br>-----END CERTIFICATE----- | The certificate authority for the kubernetes cluster |

Then run the fly command:
```bash
fly -t <target> set-pipeline -p <pipeline-name> -c pipelines/ci-latest-patch-pipeline.yml -l <path-to-secrets-yml>
```
This should give you a diff view of the proposed pipeline changes, check the changes and accept if they are correct.
