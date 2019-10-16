# -*- mode: Python -*-
allow_k8s_contexts('kubernetes-admin@kubernetes')

DOCKER_PROVIDER='cluster-api/test/infrastructure/docker'
AWS_PROVIDER='cluster-api-provider-aws'

# Set to either Docker or AWS
# infrastructure_provider = DOCKER_PROVIDER
infrastructure_provider = AWS_PROVIDER

# proj is the base dir
# args will be joined after the project if args exist
def dir(proj, *args):
	path = list(args)
	path.insert(0,proj)
	path.insert(0,'.')
	return '/'.join(path)

settings = read_json('config.json', default={})
default_registry(settings.get('default_registry'))

core_provider = 'cluster-api'
bootstrap_provider = 'cluster-api-bootstrap-provider-kubeadm'

core_image = settings.get('default_core_image')
bootstrap_image = settings.get('default_bootstrap_image')
infrastructure_image = settings.get('default_infrastructure_image')

providers = [
	{
		'name': core_provider,
		'image': core_image,
	},
	{
		'name': bootstrap_provider,
		'image': bootstrap_image,
	},
	{
		'name': infrastructure_provider,
		'image': infrastructure_image,
	},
]

for provider in providers:
	if provider['name'] == AWS_PROVIDER:
		b64credentials = local(AWS_PROVIDER + "/bin/clusterawsadm alpha bootstrap encode-aws-credentials | tr -d '\n'")
		command = '''sed -i '' -e 's@credentials: .*@credentials: '"{}"'@' {}/config/manager/credentials.yaml'''.format(b64credentials, provider['name'])
		local(command)
	command = '''sed -i '' -e 's@image: .*@image: '"{}"'@' ./{}/config/default/manager_image_patch.yaml'''.format(provider['image'], provider['name'])
	local(command)
	kustomizedir = './' + provider['name'] + '/config/default'
	# listdir(kustomizedir)
	k8s_yaml(kustomize(kustomizedir))

docker_build(core_image, './cluster-api')

docker_build(bootstrap_image, dir(bootstrap_provider), dockerfile=bootstrap_provider + '/Dockerfile.dev',
	live_update=[
		sync(dir(bootstrap_provider, 'controllers'), '/workspace/controllers'),
		sync(dir(bootstrap_provider, 'main.go'), '/workspace/main.go'),
		sync(dir(bootstrap_provider, 'api'), '/workspace/api'),
		sync(dir(bootstrap_provider, 'locking'), '/workspace/locking'),
		run('go install -v ./main.go'),
		run('mv /go/bin/main /manager'),
		run('./restart.sh'),])

## Uncomment one of the two depending on which infrastructure provider you are using

# # aws provider
def aws_docker_build():
 	docker_build(infrastructure_image, dir(infrastructure_provider), dockerfile=infrastructure_provider + '/dev.dockerfile',
		live_update=[
			sync(dir(infrastructure_provider, "pkg"), '/workspace/pkg'),
			sync(dir(infrastructure_provider, "main.go"), '/workspace/main.go'),
			run('go install -v ./cmd/manager'),
			run('mv /go/bin/manager /manager'),
			run('./restart.sh'),])

# docker provider
def docker_docker_build():
	docker_build(infrastructure_image, dir(infrastructure_provider), dockerfile=infrastructure_provider + '/Dockerfile.dev',
	live_update=[
		sync(dir(infrastructure_provider, "api"), '/workspace/api'),
		sync(dir(infrastructure_provider, "docker"), '/workspace/docker'),
		sync(dir(infrastructure_provider, "cloudinit"), '/workspace/cloudinit'),
		sync(dir(infrastructure_provider, "controllers"), '/workspace/controllers'),
		sync(dir(infrastructure_provider, "cmd", "manager", "main.go"), '/workspace/cmd/manager/main.go'),
		run('go install -v ./cmd/manager'),
		run('mv /go/bin/manager /manager'),
		run('./restart.sh'),])

if infrastructure_provider == DOCKER_PROVIDER:
	docker_docker_build()
elif infrastructure_provider == AWS_PROVIDER:
	aws_docker_build()
