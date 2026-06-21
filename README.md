# azure-zero-trust-compliance-framework
Zero Trust device compliance framework using Entra ID, Intune and Conditional Access deployed as code with location based access control

# Azure Zero Trust Compliance Framework

## Why I built this

I ran into this problem at work: we had multiple office locations and each one needed a different device compliance profile but access decisions still had to come from one consistent identity layer. Doing it manually through the Entra/Intune portal worked but it didn't scale past a couple of sites and when an auditor asked "show me exactly what policy applies to site X" there wasn't a clean answer beyond a screenshot.

This repo is that same setup rebuilt as code so the policy itself is the documentation.

## Architecture
![Zero Trust Architecture](architecture/zero-trust-architecture.png)

1. A user or device requests access to something in Azure or M365
2. Entra ID confirms identity
3. Conditional Access checks the connection context — location and device state
4. Intune supplies the compliance verdict (OS version, encryption, antivirus)
5. Access is granted if both checks pass. If not, it's blocked and the user is routed to remediation rather than a dead end

## What's in here
- `terraform/` — the Conditional Access policy as code not configured by hand through the portal
- `intune/` — the compliance policy definition behind step 4 above
- `powershell/` — two scripts. One assigns a device to the right Entra ID group based on its site. The other provisions local admin access scoped to that site rather than handing out anything global
- `docs/design-decisions.md` — why I made a few of the less obvious calls in case the code alone doesn't explain itself

## Stack
Azure Entra ID, Intune, Terraform, PowerShell, Azure Monitor

## Running it
```bash
cd terraform
terraform init
terraform plan
terraform apply
```
The PowerShell scripts are written to run via Intune script deployment not manually - that's how this would actually be used day to day.

## Tradeoffs and what I'd change with more time
Local admin here is still a standing account, scoped per site but not time-bound. With more time I'd put this behind PIM so it's just-in-time instead. I'd also add Sentinel alerting for compliance drift and a Logic App to handle the obvious remediation cases automatically instead of relying on someone noticing.

## Where this came from
This reflects a real Zero Trust rollout I led at work the location based profiles, the compliance enforcement, the scoped admin model rewritten here as infrastructure-as-code for the portfolio. It's not a tutorial project.
