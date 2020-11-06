#!/usr/bin/python3
from pprint import pprint

from chalice import Chalice, Response

from chalicelib import utils

app = Chalice(app_name='ex_app_lambda')


@app.route('/cleanup-images', methods=['POST'])
def cleanup_images():
    x_api_key = app.current_request.headers.get('x-api-key', False)
    if x_api_key:
        return {
            'pull_requests': utils.cleanup_images()
        }
    else:
        return Response(
            body={'error': 'No x-api-key found in headers'},
            status_code=403
        )


@app.route('/pull-requests')
def pull_requests():
    x_api_key = app.current_request.headers.get('x-api-key', False)
    if x_api_key:
        return {
            'pull_requests': utils.pull_requests(x_api_key)
        }
    else:
        return Response(
            body={'error': 'No x-api-key found in headers'},
            status_code=403
        )


@app.route('/unused-workspaces')
def unused_workspaces():
    x_api_key = app.current_request.headers.get('x-api-key', False)
    if x_api_key:
        current_pull_requests = utils.pull_requests(x_api_key)
        unused_workspaces_list = []
        for pr in current_pull_requests:
            if not pr['state'] == 'open' and pr['workspace_exists']:
                unused_workspaces_list.append(pr['workspace'])

        return unused_workspaces_list
    else:
        return Response(
            body={'error': 'No x-api-key found in headers'},
            status_code=403
        )


@app.route('/add-comment/{pull_request_id}', methods=['POST'])
def add_comment(pull_request_id):
    x_api_key = app.current_request.headers.get('x-api-key', False)
    if x_api_key:
        comment = app.current_request.json_body['comment']
        return utils.add_comment(x_api_key, pull_request_id, comment)
    else:
        return Response(
            body={'error': 'No x-api-key found in headers'},
            status_code=403
        )

