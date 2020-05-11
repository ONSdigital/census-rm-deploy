# Census RM Deploy
Response management Concourse pipelines and documentation

## Pipelines
### [Build Deploy Test CI WL](pipelines/build-deploy-test-CI-WL.yml)
This pipeline builds latest docker images triggered by commits to master, deploys the infrastructure and services to CI, runs the [`acceptance tests`](https://github.com/ONSdigital/census-rm-acceptance-tests) against them then deploys them to WL if they pass.

The builds/deploys/tests can be triggered by:
* Changes to our infrastructure in [`census-rm-terraform`](https://github.com/ONSdigital/census-rm-terraform) which will trigger an automatic terraform apply in CI, redeploy all services and run acceptance tests

* Changes to our k8s manifests in [`census-rm-kubernetes`](https://github.com/ONSdigital/census-rm-kubernetes).

* New commits to master in any of the tracked repos.

#### Config
Required configuration:

| Variable                    | Format                                                                              | Description                                                                                   |
| --------------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| acceptance-tests-image      | String                                                                              | The name of the acceptance tests image to run                                                 |
| terraform-branch            | String                                                                              | CI - The name of the terraform branch                                                         |
| ci-kubernetes-cluster-name  | String                                                                              | CI -The name of the kubernetes cluster                                                        |
| ci-gcp-project-name         | String                                                                              | CI- The name of the GCP project the targeted cluster belongs to                               |
| ci-gcp-admin-account-json   | \| <br>\<GCP Concourse admin account key json                                       | CI - JSON representation of a GCloud account access key with IAM permissions                  |
| wl-kubernetes-cluster-name  | String                                                                              | WL -The name of the kubernetes cluster                                                        |
| wl-gcp-project-name         | String                                                                              | WL -The name of the GCP project the targeted cluster belongs to                               |
| wl-gcp-environment-name     | String                                                                              | WL - The name of the GCP project suffix the targeted cluster belongs to                       |


#### How to validate the concourse definitions

```
./validate-pipelines.sh 
```

Expect that all files in the pipelines folder reportedly look good.


#### How to fly manually
To access fly locally, you'll now need to access it through a bastion.  Run the following at the start of a session then log into your Google account when prompted:
```bash
gcloud compute ssh bastion --project census-ci --zone europe-west2-a -- -D 1080 -f -N
export HTTPS_PROXY=socks5://localhost:1080
```

Run the fly command:
```bash
fly -t <target> set-pipeline -p <pipeline-name> -c pipelines/ci-kubernetes-pipeline.yml -l <path-to-config-yml>
```
This should give you a diff view of the proposed pipeline changes, check the changes and accept if they are correct.

### [Manual Release Pipeline](pipelines/manual-release-pipeline.yml)
This pipeline is designed for deploying release-tagged versions of following:
 * Infrastructure
 * Docker images for RM apps
 
 It fetches only commits with tags matching `v*.*.*`. The `Trigger Terraform` and `Trigger Deployment` jobs should be triggered manually by the user to deploy the active version. These jobs work by acting as a gate on the `every-minute` resource. The Terraform job and all of the individual service deploy jobs are set to trigger off the `every-minute` resource, but require the `Trigger Terraform` / `Trigger Deployment` jobs to have passed, which are only triggered manually. This allows the infrastructure and all the services to be deployed with one manual trigger of the `Trigger Terraform` / `Trigger Deployment` jobs, once every minute. The version to be deployed can be changed by selectively enabling only the desired version ref in the resource UI.
 To deploy a specific version, disable all versions above it on the resource UI, then trigger the `Trigger Terraform` / `Trigger Deployment` job. See https://concourse-ci.org/manual-trigger-example.html

#### How to fly manually
Create a config YAML file containing the required configuration:

| Variable                 | Format                                                                              | Description                                                                              |
| ------------------------ | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| kubernetes-cluster-name  | String                                                                              | The name of the kubernetes cluster                                                       |
| acceptance-tests-image   | String                                                                              | The name of the acceptance tests image to run                                            |
| gcp-environment-name     | String                                                                              | The name of the GCP project suffix the targeted cluster belongs to                       |
| gcp-project-name         | String                                                                              | The name of the GCP project targeted cluster belongs to                                                       |

#### Force checking for older versions
By default the github resource will only pick tags from the newest since the pipeline was first flown. If you need to use an older tag you can force it to check older resources versions with the [`check-resource` fly command](https://concourse-ci.org/managing-resources.html#fly-check-resource) with an appropriate `from -f` flag, e.g.

```shell-script
fly -t <target> check-resource -r <pipeline>/census-rm-kubernetes-release -f ref:v1.0.0
```

This would bring in all versions from `v1.0.0` chronologically.

### Performance Pipeline
The performance pipeline has a number of different performance tests which can be run, by first selecting which one you would like to run, and then triggering the selected test.

Presently there are three tests which can be run, by running these selection jobs:
 - Select Test - 350k
 - Select Test - 3.5 million
 - Select Test - PubSub

 Once you have run one of the selection jobs, you can then run Trigger Selected Test to run the test.

## RM sandbox
If you'd like to deploy a pipeline to the RM Sandbox concourse:
- You'll need to set your fly target to the sandbox environment e.g `fly login -t main -c https://concourse.rm.census-gcp.onsdigital.uk/`
- To run terraform you'll need to whitelist the `census-rm-concourse` ip from the Cloud Nat section in GCP
- You'll need to give the `census-rm-concourse` service account owner permission in your environment. This can be done in the IAM section in GCP.
