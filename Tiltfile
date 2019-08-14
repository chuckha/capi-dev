enable_feature("snapshots")

allow_k8s_contexts('kubernetes-admin@kubernetes')

DOCKER_PROVIDER='cluster-api-provider-docker'
AWS_PROVIDER='cluster-api-provider-aws'


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
infrastructure_provider = DOCKER_PROVIDER

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
    command = '''sed -i '' -e 's@image: .*@image: '"{}"'@' ./{}/config/default/manager_image_patch.yaml'''.format(provider['image'], provider['name'])
    local(command)
    kustomizedir = './' + provider['name'] + '/config/default'
    # listdir(kustomizedir)
    k8s_yaml(kustomize(kustomizedir))

docker_build(core_image, './cluster-api')

docker_build(bootstrap_image, dir(bootstrap_provider),
    live_update=[
        sync(dir(bootstrap_provider, 'controllers'), '/workspace/controllers'),
        sync(dir(bootstrap_provider, 'main.go'), '/workspace/main.go'),
        sync(dir(bootstrap_provider, 'api'), '/workspace/api'),
        run('go install -v ./main.go'),
        run('mv /go/bin/main /manager'),
        run('./restart.sh'),])

## Uncomment one of the two depending on which infrastructure provider you are using

# # aws provider
# docker_build(infrastructure_image, dir(infrastructure_provider),
#     live_update=[
#         sync(dir(infrastructure_provider, "pkg"), '/workspace/pkg'),
#         sync(dir(infrastructure_provider, "main.go"), '/workspace/main.go'),
#         run('go install -v ./cmd/manager'),
#         run('mv /go/bin/manager /manager'),
#         run('./restart.sh'),])

# docker provider
docker_build(infrastructure_image, dir(infrastructure_provider),
    live_update=[
        sync(dir(infrastructure_provider, "controllers"), '/workspace/controllers'),
        sync(dir(infrastructure_provider, "cmd", "manager", "main.go"), '/workspace/cmd/manager/main.go'),
        run('go install -v ./cmd/manager'),
        run('mv /go/bin/manager /manager'),
        run('./restart.sh'),])

