# Census RM Deploy
Response management Concourse pipelines and documentation

## Pipelines
### [CI Kubernetes Pipeline](pipelines/ci-kubernetes-pipeline.yml)
This pipeline has three sections:

1.The first pulls from the [`census-rm-kubernetes`](https://github.com/ONSdigital/census-rm-kubernetes) repo triggered by commits to master and applies the latest microservice and handler configs to the kubernetes cluster specified by the pipeline configuration.

1.The second checks for new builds for the `latest` tag for the RM container registry images. On being triggered by a new image build it runs the config apply to ensure the config is in line with master, then runs `kubectl patch` for the newly built images deployment giving them a timestamp and image digest label. This causes kubernetes to re-pull the latest image and bring up new pods while we are using `imagePullPolicy: Always`.

Lastly the pipelines runs the [`acceptance tests`](https://github.com/ONSdigital/census-rm-acceptance-tests) in kubernetes against the deployed services.

#### How to fly
Create a secrets YAML file containing the required configuration:

| Variable                 | Format                                                                              | Description                                                                              |
| ------------------------ | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| kubernetes-cluster-name  | String                                                                              | The name of the kubernetes cluster                                                       |
| github-private-key       | \| <br>-----BEGIN PRIVATE KEY----- <br>\<private key> <br>-----END PRIVATE KEY----- | A private SSH key for Github with permissions to clone private repositories              |
| gcp-service-account-json | \| <br>\<GCP service account key json>                                              | JSON representation of a GCloud service account access key with required IAM permissions |
| gcp-project-name         | String                                                                              | The name of the GCP project the targeted cluster belongs to                              |

Then run the fly command:
```bash
fly -t <target> set-pipeline -p <pipeline-name> -c pipelines/ci-kubernetes-pipeline.yml -l <path-to-secrets-yml>
```
This should give you a diff view of the proposed pipeline changes, check the changes and accept if they are correct.

### [Manual CI Kubernetes Pipeline](pipelines/manual-ci-kubernetes-pipeline.yml)
This is a copy of the [CI Kubernetes Pipeline](#ci-kuberenetes-pipeline) with all the automatic triggers removed. This is useful for any environment where we want to be deploying the latest docker image builds, but not necessarily as soon as they're built.

#### How to fly

Uses the same configuration as the [CI Kubernetes Pipeline](#ci-kubernetes-pipeline).
```bash
fly -t <target> set-pipeline -p <pipeline-name> -c pipelines/manual-ci-kubernetes-pipeline.yml -l <path-to-secrets-yml>
```
