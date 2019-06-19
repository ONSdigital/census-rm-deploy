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


### [Manual CI Kubernetes Pipeline](pipelines/manual-ci-kubernetes-pipeline.yml)
This is a copy of the CI section of [CI-SIT Kubernetes Pipeline](#ci-sit-kuberenetes-pipeline) with all the automatic triggers removed. This is useful for any environment where we want to be deploying the latest docker image builds, but not necessarily as soon as they're built.

#### How to fly
Create a secrets YAML file containing the required configuration:

| Variable                 | Format                                                                              | Description                                                                              |
| ------------------------ | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| kubernetes-cluster-name  | String                                                                              | The name of the kubernetes cluster                                                       |
| acceptance-tests-image   | String                                                                              | The name of the acceptance tests image to run                                            |
| github-private-key       | \| <br>-----BEGIN PRIVATE KEY----- <br>\<private key> <br>-----END PRIVATE KEY----- | A private SSH key for Github with permissions to clone private repositories              |
| gcp-service-account-json | \| <br>\<GCP service account key json>                                              | JSON representation of a GCloud service account access key with required IAM permissions |
| gcp-project-name         | String                                                                              | The name of the GCP project the targeted cluster belongs to                              |
| gcp-environment-name     | String                                                                              | The name of the GCP project suffix the targeted cluster belongs to                       |
