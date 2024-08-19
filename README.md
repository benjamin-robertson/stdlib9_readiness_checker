# stdlib9_readiness_checker

A module containing a task and plan to scan entire code environments for stdlib 9 removed functions. 

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with stdlib9_readiness_checker](#setup)
    * [Beginning with stdlib9_readiness_checker](#beginning-with-stdlib9_readiness_checker)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Puppet 8 requires upgrade to [stdlib 9][2]. Stdlib 9 has removed many [deprecated functions][1], if these functions are still in use Puppet code will fail to compile after upgrading to stdlib 9. 

Stdlib 9 should be be upgraded too prior to upgrading the Puppet 8. Stdlib 9 is supported on Puppet 7. 


## Setup

### Beginning with stdlib9_readiness_checker

Add stdlib9 readiness checker to your Puppetfile and deploy code to your Puppet primary.

Stdlib readiness checker task and plan accepts 1 parameters. 

**Environment:** Required: Name of the environment you wish to scan. This could be production, development etc. Note: the plan limits environment names to [valid environment names.][2]

The plan `stdlib9_readiness_checker` will automatically locate your Puppet primary server. To manually target a Puppet server use the task `stdlib9_readiness_checker` and select the desired target. 

These plans should also function when run by [Puppet Bolt.][4]

## Usage

From within the Puppet Enterprise console, goto plans or tasks and select `stdlib9_readiness_checker`. Fill in required values then run the task/plan.

Depending on the size of your Puppet code environment, it may take a while to return the results.

## Limitations

stdlib9_readiness_checker can be used to help prepare for the migration to stdlib 9. However it should not solely relied upon to catch all issues. Running your code on stdlib 9 within your test environment is vital before performing production upgrades.

## Development

If you find any issues with this module, please log them in the issues register of the GitHub project. [Issues][3]

PR's glady accepted. 

[1]: https://dev.to/puppet/deprecation-of-puppetlabs-stdlib-functions-3cj8
[2]: https://forge.puppet.com/modules/puppetlabs/stdlib/readme
[3]: https://github.com/benjamin-robertson/stdlib9_readiness_checker/issues
[4]: https://www.puppet.com/docs/bolt/latest/bolt.html