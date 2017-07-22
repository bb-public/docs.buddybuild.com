#!/usr/bin/env python3
"""Deploy the website to surge."""

import os, sys
import subprocess
import requests


class Deployer:
    """Responsible for deploying the website."""

    def __init__(self):
        self._repo = os.environ['TRAVIS_REPO_SLUG']
        self._pull_request = os.environ['TRAVIS_PULL_REQUEST']
        self._branch = os.environ['TRAVIS_BRANCH']
        self._github_token = os.environ['GITHUB_TOKEN']
        os.environ['AWS_SECRET_ACCESS_KEY'] # just to raise an exception if missing
        os.environ['AWS_SECRET_KEY_ID']
        self._bucketURI = os.environ['AWS_BUCKET_URL'] # e.g. s3://apidocs.buddybuild.com'
        self._bucketRegion = os.environ['AWS_BUCKET_REGION'] # e.g. us-west-2  
        self.domain = None

    def deploy(self):
        """Main function of the script."""
        # crazy env var 'syntax'
        if self._pull_request != 'false':  # we don't want to deploy anything but PRs
            self.deploy_pull_request()
        else:
            self.deploy_branch()

    def deploy_branch(self):
        """Deploy whenever a branch is pushed to github."""
        print('Deploying branch: {}'.format(self._branch))
        if self._branch == 'master':
            self.deploy_s3()
        else:
            branch = self._branch.replace('/', '-')
            self.domain = 'http://{}-bb-docs.surge.sh'.format(branch)
            self.deploy_surge()


    def deploy_s3(self):
        command = 'aws s3 sync --delete --region ' + self._bucketRegion + ' --only-show-errors _book/ ' + self._bucketURI
        print('Running command: `{}`'.format(command))
        retval = subprocess.call(command.split())
        if retval:
            raise sys.exit(retval)

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
        command = 'surge --project _book/'
        if self.domain:
            command += ' --domain {}'.format(self.domain)

        print('Running command: `{}`'.format(command))
        retval = subprocess.call(command.split())
        if retval:
            raise sys.exit(retval)

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