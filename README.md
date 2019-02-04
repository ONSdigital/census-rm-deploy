# census-rm-deploy
Response Management deployment pipelines and documentation

## Pipelines
### CI Kubernetes Pipeline
Specified in `pipelines/ci-kubernetes-pipeline.yml`, this pipeline pulls from the `census-rm-kubernetes` repo and applies the latest microservice and handler configs to the kubernetes cluster specified by the pipeline configuration.

### CI Latest Patch Pipeline
Specified in `pipelines/ci-latest-patch-pipeline.yml`, this pipeline is triggered by new builds for the `latest` tag for the RM container registry images. On being triggered by a new build, it runs a `kubectl patch` for the newly built images deployment updating a timestamp label. This causes kubernetes to re-pull the latest image since we set `imagePullPolicy: Always` on all deployments.
