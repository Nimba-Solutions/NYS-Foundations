# Using these workflows

## Initial Setup

Follow the [`Initial Setup` instructions [described in the `Development` section of the Main README](https://github.com/Nimba-Solutions/NYS-Foundations/edit/main/README.md).](https://github.com/Nimba-Solutions/NYS-Foundations/blob/main/.github/workflows/README.md#initial-setup) to configure the bootstrapped CICD for this project.

### Manual Actions

#### Promote the Latest Beta Package
1. Navigate to Your Repository > Actions > Beta - Promote (Unlocked).
2. Click `Run Workflow`.
3. Confirm.

#### Install the Latest Beta Package
1. Navigate to Your Repository > Actions > Package - Install (Unlocked).
2. Click `Run Workflow`.
3. Select `Sandbox` or `Production`.
4. Confirm.

Note: Depending on the configuration of your GitHub Organization, you may need to specify some or all of the additional permissions for these workflows to run successfully:

```yml
permissions:
  actions: write
  attestations: write
  checks: write
  contents: write
  deployments: write
  discussions: write
  issues: write
  packages: write
  pages: write
  pull-requests: write
  repository-projects: write
  security-events: write
  statuses: write
```
