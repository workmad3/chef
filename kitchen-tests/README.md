# End-To-End Testing for Chef Client
Here we seek to provide end-to-end testing of Chef Client through cookbooks which
exercise many of the available resources, providers, and common patterns. The cookbooks
here are designed to ensure certain capabilities remain functional with updates
to the client code base.

## Getting started
All the gems needed to run these tests can be installed with Bundler.

```shell
chef/kitchen-tests$ bundle install
```

To ensure everything is working properly, and to see which platforms can have tests
executed on them, run

```shell
chef/kitchen-tests$ bundle exec kitchen list
```

You should see output similar to

```shell
Instance            Driver    Provisioner  Last Action
webapp-ubuntu-1204  Vagrant   ChefSolo     <Not Created>
```

## Testing locally
We use Test Kitchen to build instances, test client code, and destroy instances. If
you are unfamiliar with Test Kitchen we recommend checking out the [Getting Started Guide](http://kitchen.ci/docs/getting-started),
though most of the information you'll need to run these tests is documented here.

### Configuring your tests
You will need to configure the provisioner before running the tests. Test Kitchen is configured
for local testing in the `.kitchen.yml` file which resides in this directory.

Kitchen uses the `chef_solo` provisioner to run chef client on a box before any tests run.
The provisioner can be configured to pull client source code from a GitHub repository using any
valid Git reference. By default, the provisioner is configured to pull your most recent commit
to `opscode/chef`. You can change this by modifying the `github:` and `branch:` options under
`provisioner:` in `.kitchen.yml`.
* `github:`: Set this to `"<your_username>/<your_chef_repo>"`. The default is `"opscode/chef"`.
* `branch:`: This can be any valid git reference (e.g., branch name, tag, or commit SHA). If omitted, it defaults to `master`.

The branch you choose **must** be accessible on GitHub. You cannot use a local commit at this time.

**Please return all provisioner settings to their original values before submitting
a pull request for review.** Unless, of course, your changes are enhancements to the default provisioner settings.

Once configured, you can run the tests against your client code:
```shell
chef/kitchen-tests$ bundle exec kitchen test
```

### Commands
Kitchen instances are led through a series of states. The instance states, and the actions
taken to transition into each state, are in order:
* `destroy`: Delete all information for and terminate one or more instances.
  * This is equivalent to running `vagrant destroy` to stop and delete a Vagrant machine.
* `create`: Start one or more instances.
  * This is equivalent to running `vagrant up --no-provision` to start a Vagrant instance.
* `converge`: Use a provisioner to configure one or more instances.
  * By default, Test Kitchen is configured to use the `ChefSolo` provisioner which:
    * Prepares local files for transfer,
    * Installs the latest release of Chef Omnibus,
    * Downloads Chef Client source code from the prescribed GitHub repository and reference,
    * Builds and installs a `chef` gem from the downloaded source,
    * Runs `chef-client`.
* `setup`: Prepare to run automated tests. Installs `busser` and related gems on one or more instances.
* `verify`: Run automated tests on one or more instances.

When transitioning between states, actions for any and all intermediate states will performed.
Executing the `create` then the `verify` commands is equivalent to executing `create`, `converge`,
`setup`, and `verify` one-by-one and in order. The only exception is `destroy`, which will
immediately transfer that machine's state to destroyed.

The `test` command takes one or more instances through all the states, in order: `destroy`, `create`,
`converge`, `setup`, `verify`, `destroy`.

To see a list of available commands, type `bundle exec kitchen help`. To see more information
about a particular command, type `bundle exec kitchen help <command>`.


## Testing pull requests
These end-to-end tests are also configured to run with Travis on EC2 instances. The configuration
for this is specified in `.kitchen.travis.yml`. Travis is set up to run these tests automatically
when a pull request is submitted or merged into the master branch of opscode/chef.

### Forked repositories
[Secure environment variables](http://docs.travis-ci.com/user/build-configuration/#Secure-environment-variables)
are used to transfer sensitive data, such as the AWS secret access key and private SSH keys, to
Travis so that it can interact with EC2 instances securely. Unfortunately, pull
requests from forked repositories [don't have access to secure environment variables](http://docs.travis-ci.com/user/pull-requests/#Security-Restrictions-when-testing-Pull-Requests).
If you are submitting a pull request from a forked repository, these tests won't be run
until the code is merged into master.

We are looking into expanding this to cover contributions from outside opscode and will
provide an update as soon as that functionality is provided.

## Contributing
We're looking for help to increase the coverage of these tests across other platforms. You are encouraged
to submit a pull request to expand test coverage of resources and providers to platforms that are important to you.
