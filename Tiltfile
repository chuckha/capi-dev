# -*- mode: Python -*-

allow_k8s_contexts('kubernetes-admin@kubernetes')

# global settings
settings = read_json('config.json', default={})
core_image = settings.get('default_core_image')

default_registry(settings.get('default_registry'))
KUSTOMIZE_DIR = 'kustomize_dir'
DIRECTORY = 'dir'
DOCKER_FILE = 'dockerfile'
CONTEXT = 'context'
IMAGE = 'image'
TARGET = 'target'

#---------------------#
# Available providers #
#---------------------#
AWS = 'aws'
DOCKER = 'docker'

#------------------------------------------#
# uncomment the provider you'd like to use #
#------------------------------------------#
#provider = DOCKER
provider = AWS

#-----------------------------------#
# necessary kubernetes dependencies #
#-----------------------------------#
# Install and wait for the cert manager webhook service to become available
local('kubectl apply  -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml')
local('kubectl wait --for=condition=Available --timeout=300s apiservice v1beta1.webhook.cert-manager.io')

#------------------------------------------------#
# define the necessary locations of the provider #
#------------------------------------------------#
infrastructure_providers = {
	DOCKER: {
		KUSTOMIZE_DIR: 'config/default',
		DIRECTORY: './cluster-api/test/infrastructure/docker',
		DOCKER_FILE: 'Dockerfile.dev',
		CONTEXT: './cluster-api', # since this provider is in tree the build context is everything
		IMAGE: 'gcr.io/k8s-staging-capi-docker/capd-manager',
		TARGET: '',
	},
	AWS: {
		KUSTOMIZE_DIR: 'config/default',
		DIRECTORY: './cluster-api-provider-aws',
		DOCKER_FILE: 'Dockerfile',
		CONTEXT: './cluster-api-provider-aws',
		IMAGE: 'gcr.io/k8s-staging-cluster-api-aws/cluster-api-aws-controller',
		TARGET: 'builder'
	},
}
provider_data = infrastructure_providers[provider]

if provider == AWS:
	b64credentials = local(provider_data[DIRECTORY] + "/bin/clusterawsadm alpha bootstrap encode-aws-credentials | tr -d '\n'")
	command = '''sed -i '' -e 's@credentials: .*@credentials: '"{}"'@' {}/config/manager/credentials.yaml'''.format(b64credentials, provider_data[DIRECTORY])
	local(command)

# install cluster api manager & CRDs
k8s_yaml(kustomize('./cluster-api/config/default'))

# install infrastructure manager & CRDs
k8s_yaml(kustomize(provider_data[DIRECTORY] + '/' + provider_data[KUSTOMIZE_DIR]))

print("building capi", core_image)
# setup images
docker_build(core_image, './cluster-api',
	target='builder',
	entrypoint='/start.sh /workspace/manager',
	ignore=['test/*'],
)

docker_build(provider_data[IMAGE], provider_data[CONTEXT],
	dockerfile=provider_data[DIRECTORY] + '/' + provider_data[DOCKER_FILE],
	target=provider_data[TARGET],
)
