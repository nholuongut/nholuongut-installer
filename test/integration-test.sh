#!/bin/bash
#
# Some basic automated tests for nholuongut-installer

set -e

readonly LOCAL_INSTALL_URL="file:///src/nholuongut-install"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Using local copy of bootstrap installer to install local copy of nholuongut-install"
./src/bootstrap-nholuongut-installer.sh --download-url "$LOCAL_INSTALL_URL" --version "ignored-for-local-install"

echo "Using nholuongut-install to install a module from the terraform-aws-ecs repo using branch"
nholuongut-install --module-name "ecs-scripts" --repo "https://github.com/nholuongut-io/terraform-aws-ecs" --branch "v0.0.1"

echo "Using nholuongut-install to install a module from the terraform-aws-ecs repo with --download-dir option"
nholuongut-install --module-name "ecs-scripts" --repo "https://github.com/nholuongut-io/terraform-aws-ecs" --branch "v0.0.1" --download-dir ~/tmp

echo "Checking that the ecs-scripts installed correctly"
configure-ecs-instance --help

echo "Using nholuongut-install to install a module from the nholuongut-install repo and passing args to it via --module-param"
nholuongut-install --module-name "dummy-module" --repo "https://github.com/nholuongut/nholuongut-installer" --tag "v0.0.25" --module-param "file-to-cat=$SCRIPT_DIR/integration-test.sh"

echo "Using nholuongut-install to install a module from the nholuongut-install repo and passing mixed args to it via --module-param"
nholuongut-install --module-name "mixed-args-module" --repo "https://github.com/nholuongut/nholuongut-installer" --ref "fix/mixed-args" --module-param "message-to-echo=Hello" --module-param "echo-override"

echo "Using nholuongut-install to install a module from the nholuongut-install repo with branch as ref"
nholuongut-install --module-name "dummy-module" --repo "https://github.com/nholuongut/nholuongut-installer" --ref "for-testing-dont-delete" --module-param "file-to-cat=$SCRIPT_DIR/integration-test.sh"

echo "Using nholuongut-install to install a module from the nholuongut-install repo with tag as ref"
nholuongut-install --module-name "dummy-module" --repo "https://github.com/nholuongut/nholuongut-installer" --ref "v0.0.25" --module-param "file-to-cat=$SCRIPT_DIR/integration-test.sh"

echo "Using nholuongut-install to install a test module from the nholuongut-install repo and test that it's args are maintained via --module-param"
nholuongut-install --module-name "args-test" --repo "https://github.com/nholuongut/nholuongut-installer" --tag "v0.0.25" --module-param 'test-args=1 2 3 *'

echo "Using nholuongut-install to install a binary from the gruntkms repo"
nholuongut-install --binary-name "gruntkms" --repo "https://github.com/nholuongut-io/gruntkms" --tag "v0.0.1"

echo "Checking that gruntkms installed correctly"
gruntkms --help

echo "Unsetting GITHUB_OAUTH_TOKEN to test installing from public repo (terragrunt)"
unset GITHUB_OAUTH_TOKEN

echo "Verifying private repo access is denied"
if nholuongut-install --binary-name "gruntkms" --repo "https://github.com/nholuongut-io/gruntkms" --tag "v0.0.1" ; then
  echo "ERROR: was able to access private repo"
  exit 1
fi

echo "Verifying public repo access is allowed"
nholuongut-install --repo 'https://github.com/nholuongut-io/terragrunt' --binary-name terragrunt --tag '~>v0.21.0'

echo "Checking that terragrunt installed correctly"
terragrunt --help
