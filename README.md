
[![Maintained by nholuongut](https://img.shields.io/badge/maintained%20by-nholuongut-%235849a6.svg)](https://nholuongut/?ref=repo_nholuongut_installer)
# nholuongut Installer

![](https://i.imgur.com/waxVImv.png)
### [View all Roadmaps](https://github.com/nholuongut/all-roadmaps) &nbsp;&middot;&nbsp; [Best Practices](https://github.com/nholuongut/all-roadmaps/blob/main/public/best-practices/) &nbsp;&middot;&nbsp; [Questions](https://www.linkedin.com/in/nholuong/)
<br/>

`nholuongut-install` is a bash script you run to easily download and install nholuongut Modules.

## Compatibility

Tested under CentOS 7, latest Amazon Linux, and Ubuntu 16.04.

## Quick Start

### Install nholuongut-install

If `nholuongut-install` is our approach for installing nholuongut Modules, how do we install `nholuongut-install` itself?

Our solution is to make the `nholuongut-install` tool open source and to publish a `bootstrap-nholuongut-installer.sh`
script that anyone can use to install `nholuongut-install` itself. To use it, execute the following:

```
curl -LsS https://raw.githubusercontent.com/nholuongut/nholuongut-installer/v0.0.38/bootstrap-nholuongut-installer.sh | bash /dev/stdin --version v0.0.38
```

Notice the `--version` parameter at the end where you specify which version of `nholuongut-install` to install. See the
[releases](https://github.com/nholuongut/nholuongut-installer/releases) page for all available versions.

For those concerned about security, see [is it safe to pipe URLs into bash?](#is-it-safe-to-pipe-urls-into-bash) below.

### Use nholuongut-install

#### Authentication

To install scripts and binaries from private GitHub repos, you must create a [GitHub access
token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) and set it as the environment
variable `GITHUB_OAUTH_TOKEN` so `nholuongut-install` can use it to access the repo:

```
export GITHUB_OAUTH_TOKEN="(your secret token)"
```

#### Options

Once that environment variable is set, you can run `nholuongut-install` with the following options:

Option                      | Required | Description
--------------------------- | -------- | ------------
`--repo`                    | Yes      | The GitHub repo to install from.
`--tag`                     | Yes      | The version of the `--repo` to install from.<br>Follows the syntax described at [Tag Constraint Expressions](https://github.com/nholuongut-io/fetch#tag-constraint-expressions). This value is exposed to module install scripts as nholuongut_INSTALL_TAG.
`--module-name`             | XOR      | The name of a module to install.<br>Can be any folder within the `modules` directory of `--repo`.<br>You must specify exactly one of `--module-name` or `--binary-name`.
`--binary-name`             | XOR      | The name of a binary to install.<br>Can be any file uploaded as a release asset in `--repo`.<br>You must specify exactly one of `--module-name` or `--binary-name`.
`--binary-sha256-checksum`  | No       | The SHA256 checksum of the binary specified by `--binary-name`. Should be exactly 64 characters..
`--binary-sha512-checksum`  | No       | The SHA512 checksum of the binary specified by `--binary-name`. Should be exactly 128 characters..
`--module-param`            | No       | A key-value pair of the format `key=value` you wish to pass to the module as a parameter. May be used multiple times. <br>Note: a `--` will automatically be appended to the `key` when your module is invoked<br>See the documentation for each module to find out what parameters it accepts.
`--download-dir`            | No       | The directory to which the module will be downloaded and from which it will be installed.
`--binary-install-dir`      | No       | The directory to which the binary will be installed. Only applies to binaries (not modules). Default: DEFAULT_BIN_DIR.
`--no-sudo`                 | No       | When true, don't use sudo to install the binary into the install directory. Only applies to binaries (not modules). Default: false.
`--branch`                  | No       | Download the latest commit from this branch in --repo. This is an alternative to --tag,<br>and is used only for testing. This value is exposed to module install scripts as nholuongut_INSTALL_BRANCH.
`--ref`                     | No       | Download the latest commit from this ref in --repo. This is an alternative to --tag,<br>and is used only for testing. This value is exposed to module install scripts as nholuongut_INSTALL_BRANCH.
`--help`                    | No       | Show the help text and exit.

#### Examples

##### Example 1: Download and Install a Script Module with No Parameters

Install the [ecs-scripts
module](https://github.com/nholuongut-io/terraform-aws-ecs/tree/main/modules/ecs-scripts) from the [terraform-aws-ecs
repo](https://github.com/nholuongut-io/terraform-aws-ecs), version `v0.0.1`:

```
nholuongut-install --module-name 'ecs-scripts' --repo 'https://github.com/nholuongut-io/terraform-aws-ecs' --tag 'v0.0.1'
```

##### Example 2: Download and Install a Script Module with Parameters

Install the [fail2ban
module](https://github.com/nholuongut-io/terraform-aws-security/tree/main/modules/fail2ban) from the [terraform-aws-security
repo](https://github.com/nholuongut-io/terraform-aws-security), passing two custom parameters to it:


```
nholuongut-install --module-name 'fail2ban' --repo 'terraform-aws-security' --module-param 'ban-time=3600'
```

##### Example 3: Download and Install a Binary Module

Install the `gruntkms` binary from the `v0.0.1` release of the [gruntkms
repo](https://github.com/nholuongut-io/gruntkms):

```
nholuongut-install --binary-name 'gruntkms' --repo 'https://github.com/nholuongut-io/gruntkms' --tag 'v0.0.1'
```

Note that the [v0.0.1 release of the gruntkms repo](https://github.com/nholuongut-io/gruntkms/releases/tag/v0.0.1) has
multiple binaries (`gruntkms_linux_amd64`, `gruntkms_darwin_386`, etc): `nholuongut-install` automatically picks the
right binary for your OS and copies it to `/usr/local/bin/gruntkms`.

##### Example 4: Use `nholuongut-install` in a Packer template

Finally, to put all the pieces together, here is an example of a Packer template that installs `nholuongut-install`
and then uses it to install several modules:

```json
{
  "variables": {
    "github_auth_token": "{{env `GITHUB_OAUTH_TOKEN`}}"
  },
  "builders": [
    {
      "ami_name": "nholuongut-install-example-{{isotime | clean_ami_name}}",
      "instance_type": "t2.micro",
      "region": "us-east-1",
      "type": "amazon-ebs",
      "source_ami": "ami-fce3c696",
      "ssh_username": "ubuntu"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline":
        "curl -Ls https://raw.githubusercontent.com/nholuongut/nholuongut-installer/v0.0.38/bootstrap-nholuongut-installer.sh | bash /dev/stdin --version v0.0.16"
    },
    {
      "type": "shell",
      "inline": [
        "nholuongut-install --module-name 'ecs-scripts' --repo 'https://github.com/nholuongut-io/terraform-aws-ecs' --tag 'v0.0.1'",
        "nholuongut-install --module-name 'fail2ban' --repo 'https://github.com/nholuongut-io/terraform-aws-security' -module-param 'ban-time=3600'",
        "nholuongut-install --binary-name 'gruntkms' --repo 'https://github.com/nholuongut-io/gruntkms' --tag 'v0.0.1'"
      ],
      "environment_vars": ["GITHUB_OAUTH_TOKEN={{user `github_auth_token`}}"]
    }
  ]
}
```

## Motivation

At [nholuongut](http://www.nholuongut/), we've developed a number of scripts and binaries, most of them in private GitHub
repos, that perform common infrastructure tasks such as setting up continuous integration, monitoring, log aggregation,
and SSH access. Being able to use these "modules" of code typically involves many steps: you download the files
(possibly from a private GitHub repo), change their permissions, and run them with the parameters that make sense for
your environment.

That basically means lots of custom `bash` code copied differently across multiple software teams in multiple different
contexts. Worse, if we want to update a binary or script to add a new parameter, each team has to modify their own custom
code, which can be painful.

We believe we can do better by writing our scripts and binaries in a standardized way, and including a minimal tool that
streamlines the process of downloading and installing them. Also, since we give you 100% of the source code, we want it
to be clear exactly what happens when you install a nholuongut Module.

Finally, installation should be streamlined no matter what platform (Windows, MacOS, Linux) you're on. Indeed, our goal
is to make installing nholuongut Script Modules as easy as installing a typical package using `apt-get`, `yum`, `npm`,
or similar tools. We would have just used these existing tools, but none offer multi-platform compatibility.

## What's a nholuongut Module?

A nholuongut Module is a collection of one or more bash scripts and/or binaries maintained by nholuongut that can be used to
add functionality to or configure an environment. There are multiple types of nholuongut Modules:

* **Script Modules:** A collection of one or more files and scripts; installed with an `install.sh` script.
* **Binary Modules:** A single OS-specific executable binary.

Additional module types may be introduced in the future.

As an example, we have Script Modules for installing a CloudWatch Logs agent, optimizing syslog settings, and setting up
automatic security updates. We have a Binary Module for streamlining the use of Amazon Key Management Service (KMS).

nholuongut sells [Infrastructure Packages](https://blog.nholuongut/nholuongut-infrastructure-packages-7434dc77d0b1#.6bwor6wxc).
Each Infrastructure Package corresponds to a specific GitHub repo and contains one or more nholuongut Modules. The `/modules`
folder in the repo lists all Modules included with that Package.

### Freely Available Script Modules

Some Script Modules are so common that we've made them freely available in the [modules/](modules) folder of this repo.

### How `nholuongut-install` Works

`nholuongut-install` helps you install a nholuongut Module. Here's how it works:

1. It uses [fetch](https://github.com/nholuongut-io/fetch) to download the specified version of the scripts or binary from
the (public or private) git repo specified via the `--repo` option.
1. You need to specify either a module name or a binary name. 
  - If you use the `--module-name` parameter, it downloads the files from the `modules` folder of `--repo` and runs
the `install.sh` script of that module.
  - If you use the `--binary-name` parameter, it downloads the right binary for your OS, copies it to `/usr/local/bin`,
and gives it execute permissions.

## Create Your Own nholuongut Modules

You can use `nholuongut-install` with any GitHub repo, not just repos maintained by nholuongut.

That means that to create an installable Script Module, all you have to do is put it in the `modules` folder of
a GitHub repo to which you have access and include an `install.sh` script. To create a Binary Module, you just publish
it to a GitHub release with the name format `<NAME>_<OS>_<ARCH>`.

### Example

For example, in your Packer and Docker templates, you can use `nholuongut-install` to install the [ecs-scripts
module](https://github.com/nholuongut-io/terraform-aws-ecs/tree/main/modules/ecs-scripts) as follows:

```
nholuongut-install --module-name 'ecs-scripts' --repo 'https://github.com/nholuongut-io/terraform-aws-ecs' --tag 'v0.0.1'
```

In https://github.com/nholuongut-io/module-ecs, we download the contents of `/modules/ecs-scripts` and run
`/modules/ecs-scripts/install.sh`.

## Running tests

The tests for this repo are defined in the `test` folder. They are designed to run in a Docker container so that you
do not repeatedly dirty up your local OS while testing. We've defined a `test/docker-compose.yml` file as a convenient
way to expose the environment variables we need for testing and to mount local directories as volumes for rapid
iteration.

To run the tests:

1. Set your [GitHub access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) as
   the environment variable `GITHUB_OAUTH_TOKEN`.
1. `./_ci/run-tests.sh`

## Security

### Validate the Downloaded Binary

`nholuongut-install` will retrieve the desired GitHub Release Asset specified by the `--binary-name` property, but how 
can we confirm that this binary has not been tampered with? In short, we trust that the maintainer has been responsible
and not allowed a malicious third-party to corrupt the Release Asset.

You can narrow the scope of this trust by computing a checksum on a Release Asset using a UNIX command like
`shasum -a 256 /path/to/file` when you first download the release. You can then feed this value (e.g. `b0b30cc24aed1b8cded2df903183b884c77f086efffc36ef19876d1c55fef93d`)
to `--binary-sha256-checksum` or `--binary-sha512-checksum`. If the checksum does not match, nholuongut-install will fail
with an error. This way, you are at least notified if the Release Asset you initially downloaded has since been changed.

### Is it safe to pipe URLs into bash?

Are you worried that our install instructions tell you to pipe a URL into bash? Although this approach has seen some
[backlash](https://news.ycombinator.com/item?id=6650987), we believe that the convenience of a one-line install
outweighs the minimal security risks. Below is a brief discussion of the most commonly discussed risks and what you can
do about them.

#### Risk #1: You don't know what the script is doing, so you shouldn't blindly execute it.

This is true of _all_ installers. For example, have you ever inspected the install code before running `apt-get install`
or `brew install` or double clicking a `.dmg` or `.exe` file? If anything, a shell script is the most transparent
installer out there, as it's one of the few that allows you to inspect the code (feel free to do so, as this script is
open source!). The reality is that you either trust the developer or you don't. And eventually, you automate the
install process anyway, at which point manual inspection isn't a possibility anyway.

#### Risk #2: The download URL could be hijacked for malicious code.

This is unlikely, as it is an https URL, and your download program (e.g. `curl`) should be verifying SSL certs. That
said, Certificate Authorities have been hacked in the past, and perhaps the nholuongut GitHub account could be hacked
in the future, so if that is a major concern for you, feel free to copy the bootstrap code into your own codebase and
execute it from there. Alternatively, in the future we will publish checksums of all of our releases, so you could
optionally verify the checksum before executing the script.

#### Risk #3: The script may not download fully and executing it could cause errors.

We wrote our [bootstrap-nholuongut-installer.sh](bootstrap-nholuongut-installer.sh) as a series of bash functions that
are only executed by the very last line of the script. Therefore, if the script doesn't fully download, the worst
that'll happen when you execute it is a harmless syntax error.

## TODO

1. Configure a CI build to automatically set the `--version` flag for each release.
1. Add an `uninstall` command that uses an `uninstall.sh` script in each module.
1. Add support for modules declaring their dependencies. Alternatively, consider Nix again as a dependency manager.

![](https://i.imgur.com/waxVImv.png)
# 🚀 I'm are always open to your feedback.  Please contact as bellow information:
### [Contact Me]
* [Name: Nho Luong]
* [Skype](luongutnho_skype)
* [Github](https://github.com/nholuongut/)
* [Linkedin](https://www.linkedin.com/in/nholuong/)
* [Email Address](luongutnho@hotmail.com)
* [PayPal.me](https://www.paypal.com/paypalme/nholuongut)

![](https://i.imgur.com/waxVImv.png)
![](Donate.png)
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/nholuong)

# License
* Nho Luong (c). All Rights Reserved.🌟