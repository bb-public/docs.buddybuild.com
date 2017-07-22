#!/usr/bin/env python3
"""Deploy the website to surge."""

import os
import requests


class Deployer:
    """Responsible for deploying the website."""

    def __init__(self):
        self._repo = os.environ['TRAVIS_REPO_SLUG']
        self._pull_request = os.environ['TRAVIS_PULL_REQUEST']
        self._branch = os.environ['TRAVIS_BRANCH']
        self._github_token = os.environ['GITHUB_TOKEN']
        self.domain = None

    def deploy(self):
        """Main function of the script."""
        if self._pull_request == 'false':
            self.deploy_branch()
        else:
            self.deploy_pull_request()

    def deploy_branch(self):
        """Deploy whenever a branch is pushed to github."""
        print('Deploying branch: {}'.format(self._branch))
        if self._branch != 'master':
            branch = self._branch.replace('/', '-')
            self.domain = 'http://{}-bb-docs.surge.sh'.format(branch)
        self.deploy_surge()

    def deploy_pull_request(self):
        """Deploy whenever a pull request is made."""
        print('Deploying pull request: {}'.format(self._pull_request))
        self.domain = 'http://{}-bb-docs.surge.sh'.format(self._pull_request)
        self.deploy_surge()
        self._post_comment()

    def deploy_surge(self):
        """
        Trigger a deploy to surge.sh or to production if branch is master.
        """
        command = 'surge --project ./'
        if self.domain:
            command += ' --domain {}'.format(self.domain)

        print('Running command: `{}`'.format(command))
        os.system(command)

    def _post_comment(self):
        """Post a comment on the PR linking to the deployment."""
        url = 'https://api.github.com/repos/{}/issues/{}/comments'.format(
            self._repo, self._pull_request)
        headers = {'Authorization': 'token {}'.format(self._github_token)}
        data = {'body': 'See the website here: {}'.format(self.domain)}
        print('Posting comment to: {}'.format(url))
        requests.post(url, headers=headers, json=data)


if __name__ == '__main__':
    deployer = Deployer()
    deployer.deploy()