# -*- mode: Python -*-

allow_k8s_contexts('kubernetes-admin@kubernetes')

# global settings
settings = read_json('config.json', default={})
core_image = settings.get('default_core_image')
infrastructure_image = settings.get('default_infrastructure_image')

default_registry(settings.get('default_registry'))
KUSTOMIZE_DIR = 'kustomize_dir'
DIRECTORY = 'dir'

#######################
# Available providers #
#######################
AWS = 'aws'
DOCKER = 'docker'

############################################
# uncomment the provider you'd like to use #
############################################
provider = DOCKER
# provider = AWS

# install cluster api (always)
k8s_yaml(kustomize('./cluster-api/config/default'))

infrastructure_providers = {
	DOCKER: {
		KUSTOMIZE_DIR: 'config/default',
		DIRECTORY: './cluster-api/test/infrastructure/docker',
	},
	AWS: {
		KUSTOMIZE_DIR: 'config/default',
		DIRECTORY: './cluster-api-provider-aws',
	},
}
provider_data = infrastructure_providers[provider]

if provider == AWS:
	b64credentials = local(provider_data[DIRECTORY] + "/bin/clusterawsadm alpha bootstrap encode-aws-credentials | tr -d '\n'")
	command = '''sed -i '' -e 's@credentials: .*@credentials: '"{}"'@' {}/config/manager/credentials.yaml'''.format(b64credentials, provider_data[DIRECTORY])
	local(command)

# install infrastructure
k8s_yaml(kustomize(provider_data[DIRECTORY] + '/' + provider_data[KUSTOMIZE_DIR]))

# setup images
docker_build(core_image, './cluster-api', context='./cluster-api', target='builder')
docker_build(infrastructure_image, provider_data[DIRECTORY], context=provider_data[DIRECTORY])
