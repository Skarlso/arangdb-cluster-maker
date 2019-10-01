import os
from subprocess import check_output, STDOUT
import sys
import click

kind = None
kubectl = None


def apply(file):
    check_output(
        f'{kubectl} apply -f {file}',
        stderr=STDOUT,
        shell=True
    )


def create_cluster_func(config):
    """
    Helper function for the create_cluster sub command and the wizard.
    :param config:
    :return:
    """
    config_dir = os.path.dirname(os.path.abspath(__file__))
    config = os.path.join(config_dir, config)
    print(f'running kind create cluster --config {config}')
    check_output(
        f"{kind} create cluster --config {config}",
        stderr=STDOUT,
        shell=True
    )


def create_arango_deployment_func(version, storage, replication):
    """
    Helper function for the create_arango_deployment_func sub command and the wizard.
    :param version:
    :param storage:
    :param replication:
    :return:
    """
    apply(f'https://raw.githubusercontent.com/arangodb/kube-arangodb/{version}/manifests/arango-crd.yaml')
    apply(f'https://raw.githubusercontent.com/arangodb/kube-arangodb/{version}/manifests/arango-deployment.yaml')
    if storage:
        apply(f'https://raw.githubusercontent.com/arangodb/kube-arangodb/{version}/manifests/arango-storage.yaml')
    if replication:
        apply(f'https://raw.githubusercontent.com/arangodb/kube-arangodb/{version}/manifests/arango-deployment-replication.yaml')


@click.group()
def group():
    pass


@group.command()
@click.option('--version', default='master', help='The version to deploy.')
@click.option('--config', default='kind_cluster.yaml', help='The name of the configuration file to use.')
@click.option('--storage', is_flag=False, help='Create persistent storage.')
@click.option('--replication', is_flag=False, help='Create ArangoDeploymentReplication.')
def wizard(version, config, storage, replication):
    print('Creating cluster and deploying arango deployments.')
    create_cluster_func(config)
    print('exporting cluster settings')
    config_path = check_output(f'{kind} get kubeconfig-path --name="kind"', shell=True)
    config_path = config_path.decode(sys.stdout.encoding).strip()
    print(f"exporting kind config path {config_path}")
    os.environ['KUBECONFIG'] = config_path
    print('Creating cluster done... deploying arango ')
    create_arango_deployment_func(version, storage, replication)
    print('done.')
    print('run kind get kubeconfig-path --name="kind" to setup your local shell for the cluster')


@group.command()
@click.option('--version', default='master', help='The version to deploy.')
@click.option('--storage', is_flag=False, help='Create persistent storage')
@click.option('--replication', is_flag=False, help='Create ArangoDeploymentReplication')
def create_arango_deployment(version, storage, replication):
    create_arango_deployment_func(version, storage, replication)


@group.command()
@click.option('--config', default='kind_cluster.yaml', help='The name of the configuration file to use.')
def create_cluster(config):
    create_cluster_func(config)


@group.command()
@click.option('--config', default="", help='The service configuration to use.')
def add_db(config):
    print('adding database deployment')
    config_dir = os.path.dirname(os.path.abspath(__file__))
    config = os.path.join(config_dir, config)
    apply(config)


@group.command()
def destroy_cluster():
    check_output(f'{kind} delete cluster', shell=True)


cli = click.CommandCollection(sources=[group])

if __name__ == '__main__':
    swag = """
 _______  _______  _______  _        _______  _______  ______   ______     _______  _                 _______ _________ _______  _______
(  ___  )(  ____ )(  ___  )( (    /|(  ____ \(  ___  )(  __  \ (  ___ \   (  ____ \( \      |\     /|(  ____ \\__   __/(  ____ \(  ____ )
| (   ) || (    )|| (   ) ||  \  ( || (    \/| (   ) || (  \  )| (   ) )  | (    \/| (      | )   ( || (    \/   ) (   | (    \/| (    )|
| (___) || (____)|| (___) ||   \ | || |      | |   | || |   ) || (__/ /   | |      | |      | |   | || (_____    | |   | (__    | (____)|
|  ___  ||     __)|  ___  || (\ \) || | ____ | |   | || |   | ||  __ (    | |      | |      | |   | |(_____  )   | |   |  __)   |     __)
| (   ) || (\ (   | (   ) || | \   || | \_  )| |   | || |   ) || (  \ \   | |      | |      | |   | |      ) |   | |   | (      | (\ (
| )   ( || ) \ \__| )   ( || )  \  || (___) || (___) || (__/  )| )___) )  | (____/\| (____/\| (___) |/\____) |   | |   | (____/\| ) \ \__
|/     \||/   \__/|/     \||/    )_)(_______)(_______)(______/ |/ \___/   (_______/(_______/(_______)\_______)   )_(   (_______/|/   \__/
    """
    print(swag)

    from shutil import which
    kind = which('kind')
    if kind is None:
        print('kind not found on path')
        sys.exit(1)
    kubectl = which('kubectl')
    if kubectl is None:
        print('kubectl not found on path')
        sys.exit(1)

    cli()
