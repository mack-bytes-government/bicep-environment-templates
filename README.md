# Bicep Environment Templates

This repo is designed to provide a collection of bicep templates and composite actions to help facilitate workflows and infrastructure-as-code deployments for projects focused on Azure Government and the broader mack-bytes-government organization.  These artifacts are published here to make it easy to consume and utilize these as part of your own deployments.  

The key elements in this repo are:

- **Bicep Modules:** These bicep modules provide "lego bricks" for assembling your infrastructure-as-code" deployments and are built to meet the specification of Government customers and impact levels.  
- **Developer Scripts:** These scripts are designed to include common operations that are designed to provide "easy-buttons" to prevent having to lookup what each of these steps is, and how they work.  
- **Github Composite Actions:** These are composite actions designed specifically to be atomic and reusable in a variety of situations.  The intention being that these are common steps to prevent technical debt, improve quality, and increase stability by leveraging a single code instance.  

## Bicep Modules

TBD

## Developer Scripts

TBD

## Github Composite Actions:

Implemented in this repo are composite actions that you can leverage as part of your github workflows.  The intention being that we provide a common reusable implementation to make life easier and improve stability.  

All of the composite actions can be found in the "composite-actions" directory.  Below is a sample of how to implement them in your own repo:

```
name: test get agent details
on: 
    workflow-dispatch:

jobs:
  test-get-agent-details:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - uses: mack-bytes-government/bicep-environment-templates/composite-actions/get-agent-details@get-agent-details-latest
```

When identifying the "@" value at the end of the line, you have 2 options:

1. You can use "@main" which will always pull the "main" branch version that is available.  That does mean that you will always being using the latest, and if the parameter signature changes, it wil fail.  
2. You can pin to the "latest" of that action file, by using "@__ACTION_NAME__-latest" (for example: get-agent-details-latest).  This is predominantly used for testing.  
3. You can pin to a specific version number, by using "@__ACTION_NAME__-__VERSION_NUMBER__" (for example: get-agent-details-1.0.0), this will pin you to a specific release.  