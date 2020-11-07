#!/usr/bin/python3
import os

import boto3
import requests
from chalice import Response
from github import Github
from pprint import pprint

# TODO: Make comments
from github.GithubException import UnknownObjectException


def check_api_key(current_request):
    x_api_key = current_request.headers.get('x-api-key', False)
    if not x_api_key:
        return Response(
            body='hello world!',
            status_code=403,
        )


def is_deployment_ready(url):
    try:
        r = requests.get(
            url,
            allow_redirects=True,
            timeout=2.0,
        )
        return r.status_code < 500
    except requests.ConnectionError:
        return False


def ecr_used_images():
    used_images = []
    ecs = boto3.client('ecs')
    response = ecs.list_clusters()
    for c in response['clusterArns']:
        tasks = ecs.list_tasks(cluster=c)['taskArns']
        if len(tasks) > 0:
            task_details = ecs.describe_tasks(
                cluster=c,
                tasks=tasks
            )['tasks']
            for t in task_details:
                for c in t['containers']:
                    if os.environ.get('AWS_ECR_NAME') in c['image']:
                        used_images.append(c['image'].split(':')[1])
    return used_images


def ecr_images():
    used_images = ecr_used_images()
    images = []
    ecr = boto3.client('ecr')
    response = ecr.list_images(
        registryId=os.environ.get('AWS_ACCOUNT_ID'),
        repositoryName=os.environ.get('AWS_ECR_NAME')
    )
    for i in response['imageIds']:
        i['used'] = i['imageTag'] in used_images
        images.append(i)

    return images


def terraform_workspaces():
    workspaces = []
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(
        Bucket=os.environ.get('TF_STATE_BUCKET'),
        Prefix='env:/',
        MaxKeys=100
    )
    for ws in response['Contents']:
        ws_name = ws['Key'].split('/')[1]
        if ws_name != 'production':
            workspaces.append(ws_name)

    return workspaces


def cleanup_images():
    ecr = boto3.client('ecr')
    to_remove = []
    removed_count = 0
    for i in ecr_images():
        if not i['used']:
            del(i['used'])
            to_remove.append(i)
            removed_count += 1

    if len(to_remove) > 0:
        ecr.batch_delete_image(
            registryId=os.environ.get('AWS_ACCOUNT_ID'),
            repositoryName=os.environ.get('AWS_ECR_NAME'),
            imageIds=to_remove
        )
    return {'removed_images': removed_count}


def pull_requests(github_access_token):
    pull_request_list = []
    gh = Github(github_access_token)
    repo = gh.get_repo(os.environ.get('GITHUB_PROJECT'))
    workspaces = terraform_workspaces()

    pr_list = repo.get_pulls(state='all', sort='created')

    for pr in pr_list:
        preview_url = 'https://{}-{}-{}.{}'.format(
            os.environ.get('APP_NAME'),
            os.environ.get('APP_PREVIEW_PREFIX'),
            pr.number,
            os.environ.get('APP_DOMAIN')
        )
        workspace_name = 'preview_' + str(pr.number)

        pull_request_list.append({
            'number': pr.number,
            'title': pr.title,
            'state': pr.state,
            'from_label': pr.head.label,
            'from_sha': pr.head.sha,
            'into_label': pr.base.label,
            'into_sha': pr.base.sha,
            'preview_url': preview_url,
            'workspace': workspace_name,
            'workspace_exists': workspace_name in workspaces,
            'created_at': str(pr.created_at),
            'updated_at': str(pr.updated_at)
        })
        # print(pr.create_issue_comment("WORKS"))
        # pprint(vars(pr))
        # return gh.get_user().get_repos()
    return pull_request_list


def add_comment(github_access_token, pull_request_id, comment):
    gh = Github(github_access_token)
    repo = gh.get_repo(os.environ.get('GITHUB_PROJECT'))
    try:
        pull_request = repo.get_pull(int(pull_request_id))
        pull_request.create_issue_comment(comment)
        return {"ok": "Comment created"}

    except UnknownObjectException:
        return {"error": "Pull request " + pull_request_id + " does not exist."}
