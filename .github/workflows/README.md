# Using these workflows

## Initial Setup
1. Navigate to Your Repository > Settings > Secrets and Actions > Actions
2. Create or Update your `DEV_HUB_AUTH_URL` Repository Secret with your Dev Hub's `sfdxAuthUrl` ([How do I obtain an `sfdxAuthUrl`?](https://github.com/Nimba-Solutions/.github/wiki/Obtain-an-SFDX-Auth-URL))
3. [OPTIONAL] Update `SANDBOX_ORG_AUTH_URL` with your UAT Sandbox `sfdxAuthUrl`
4. [OPTIONAL] Update `PROD_ORG_AUTH_URL` with your Production `sfdxAuthUrl`

## Releases
### Automated Actions
1. Navigate to your project in nimba.dev
2. Create / Go To a Task record.
3. In the `Developer` card, click "Assign" and select yourself.
4. Click `Create Org` (NOT `Create Scratch Org`).
5. Do some work & retrieve your changes through nimba.dev.
6. When you're ready, click `Submit Task for Testing` in nimba.dev.
7. Click `View Pull Request`
8. Confirm the `Feature - Test (Unlocked)` job is processing.
   - If the PR target is `main`, the `Beta - Create (Unlocked)` job should also be processing. 
9. Upon success, merge the pull request.

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
