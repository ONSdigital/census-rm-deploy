# Census RM Deploy
Response management Concourse pipelines and documentation

## Pipelines
### [CI-SIT Kubernetes Pipeline](pipelines/ci-sit-kubernetes-pipeline.yml)
This pipeline deploys the infrastructure and services to CI, runs the [`acceptance tests`](https://github.com/ONSdigital/census-rm-acceptance-tests) against them then deploys them to SIT if they pass.

The deploys/tests can be triggered by:
* Changes to our infrastructure in [`census-rm-terraform`](https://github.com/ONSdigital/census-rm-terraform) which will trigger an automatic terraform apply in CI, redeploy all services and run acceptance tests

* Changes to our k8s manifests in [`census-rm-kubernetes`](https://github.com/ONSdigital/census-rm-kubernetes).

* New builds for the `latest` tag for the RM service docker images. On being triggered by a new image build it applies the config to ensure it is in line with master, then runs `kubectl patch` for the newly built image deployments giving them a timestamp and image digest label. This causes kubernetes to re-pull the latest image and bring up new pods while we are using `imagePullPolicy: Always`.

#### How to fly
Create a secrets YAML file containing the required configuration:

| Variable                    | Format                                                                              | Description                                                                                   |
| --------------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| github-private-key          | \| <br>-----BEGIN PRIVATE KEY----- <br>\<private key> <br>-----END PRIVATE KEY----- | A private SSH key for Github with permissions to clone private repositories                   |
| acceptance-tests-image      | String                                                                              | The name of the acceptance tests image to run                                                 |
| terraform-branch            | String                                                                              | CI - The name of the terraform branch                                                         |
| ci-kubernetes-cluster-name  | String                                                                              | CI -The name of the kubernetes cluster                                                        |
| ci-gcp-service-account-json | \| <br>\<GCP service account key json>                                              | CI -JSON representation of a GCloud service account access key with required IAM permissions  |
| ci-gcp-project-name         | String                                                                              | CI- The name of the GCP project the targeted cluster belongs to                               |
| ci-gcp-admin-account-json   | \| <br>\<GCP Concourse admin account key json                                       | CI - JSON representation of a GCloud account access key with IAM permissions                  |
| ci-gcp-environment-name     | String                                                                              | CI - The name of the GCP project suffix the targeted cluster belongs to                       |
| ci-kubernetes-cluster-name  | String                                                                              | SIT -The name of the kubernetes cluster                                                        |
| sit-gcp-service-account-json | \| <br>\<GCP service account key json>                                              | SIT - JSON representation of a GCloud service account access key with required IAM permissions |
| sit-gcp-project-name         | String                                                                              | SIT -The name of the GCP project the targeted cluster belongs to                               |
| sit-gcp-environment-name     | String                                                                              | SIT - The name of the GCP project suffix the targeted cluster belongs to                       |


Then run the fly command:
```bash
fly -t <target> set-pipeline -p <pipeline-name> -c pipelines/ci-kubernetes-pipeline.yml -l <path-to-secrets-yml>
```
This should give you a diff view of the proposed pipeline changes, check the changes and accept if they are correct.

### [Dev Kubernetes Pipelines](pipelines/dev-kubernetes-pipeline.yml)
This is the same as the CI section of the [CI-SIT Kubernetes Pipeline](#ci-sit-kubernetes-pipeline). It will deploy infrastucture, services and run acceptance tests in a single dev environment. 

#### How to fly
Create a secrets YAML file containing the required configuration:

| Variable                  | Format                                                                              | Description                                                                              |
| ------------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| kubernetes-cluster-name   | String                                                                              | The name of the kubernetes cluster                                                       |
| acceptance-tests-image    | String                                                                              | The name of the acceptance tests image to run                                            |
| terraform-branch          | String                                                                              | The name of the terraform branch                                                         |
| github-private-key        | \| <br>-----BEGIN PRIVATE KEY----- <br>\<private key> <br>-----END PRIVATE KEY----- | A private SSH key for Github with permissions to clone private repositories              |
| gcp-service-account-json  | \| <br>\<GCP service account key json>                                              | JSON representation of a GCloud service account access key with required IAM permissions |
| gcp-project-name          | String                                                                              | The name of the GCP project the targeted cluster belongs to                              |
| gcp-environment-name      | String                                                                              | The name of the GCP project suffix the targeted cluster belongs to                       |
| ci-gcp-admin-account-json | \| <br>\<GCP Concourse admin account key json                                       | JSON representation of a GCloud account access key with IAM permissions                  |


### [Manual Release Pipeline](pipelines/manual-release-pipeline.yml)
This pipeline is designed for deploying release tagged versions of the docker images, but not necessarily as soon as they're built. It fetches only commits with tags matching `v*.*.*`. The `Deploy` job is what should be triggered manually by the user to deploy the active version. This works by acting as a gate on the `every-minute` resource. All the individual service deploy jobs are set to trigger off the `every-minute` resource but require the `Deploy` job to have passed, which is only triggered manually. This allows all the services to be deployed with one manual trigger of the `Deploy` job, once every minute. The version to be deployed can be changed by selectively enabling only the desired version ref in the resource UI.
 To deploy a specific version, disable all versions above it on the resource UI, then trigger the `Deploy` job. See https://concourse-ci.org/manual-trigger-example.html

#### How to fly
Create a secrets YAML file containing the required configuration:

| Variable                 | Format                                                                              | Description                                                                              |
| ------------------------ | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| kubernetes-cluster-name  | String                                                                              | The name of the kubernetes cluster                                                       |
| acceptance-tests-image   | String                                                                              | The name of the acceptance tests image to run                                            |
| gcp-environment-name     | String                                                                              | The name of the GCP project suffix the targeted cluster belongs to                       |
| gcp-project-name         | String                                                                              | The name of the GCP project targeted cluster belongs to                                                       |

#### Force checking for older versions
By default the github resource will only pick tags from the newest since the pipeline was first flown. If you need to use an older tag you can force it to check older resources versions with the [`check-resource` fly command](https://concourse-ci.org/managing-resources.html#fly-check-resource) with an appropraite `from`, e.g.

```shell-script
fly -t <target> check-resource -r <pipeline>/census-rm-kubernetes-release -f ref:v1.0.0
```

This would bring in all versions from `v1.0.0` chronologically.
