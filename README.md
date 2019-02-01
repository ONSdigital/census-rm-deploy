# census-rm-deploy
Response Management deployment pipelines and documentation

# Pipelines
### CI Kubernetes Pipeline
Specified in `ci-kubernetes-pipeline.yml`, this pipeline pulls from the `census-rm-kubernetes` repo and applies the latest microservice and handler configs to the kubernetes cluster specified by the pipeline configuration.
