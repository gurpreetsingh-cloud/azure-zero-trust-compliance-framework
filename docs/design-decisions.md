# Design Decisions

A few notes on choices made in this project that might not be obvious just
from reading the code.

## Why two separate Conditional Access policies instead of one

I could have combined the "require compliant device + MFA outside trusted
locations" logic and the "block non-compliant devices outright" logic into
a single policy. I split them deliberately:

- They answer different questions. One is about *where* you're connecting
  from, the other is about *device health* regardless of location.
- Keeping them separate means either can be adjusted or disabled
  independently without affecting the other. If trusted site IP ranges
  change, that's a one-policy edit, not a re-read of a much bigger
  combined ruleset.
- During a rollout, this also lets you stage things — enable the
  compliance block first, monitor for false positives, then layer in the
  location-based MFA requirement once you're confident the compliance
  signal itself is reliable.

## Why site-scoped local admin accounts instead of one shared account

The original requirement (from the real-world version of this problem)
was that each site needed local admin capability, with a shared password
per site. The simplest version of that is one global local admin account
used everywhere.

I didn't do that, because a single shared global admin account is a
single point of failure — if it leaks, every device everywhere is
exposed. Scoping the account per site (`ladmin-SiteA`, `ladmin-SiteB`,
etc.) means a compromise at one site doesn't cascade everywhere else.
It's a small naming convention, but it changes the blast radius
significantly.

The honest tradeoff: this is still a standing account with a static
password, not a just-in-time credential. With more time, this would
move behind Privileged Identity Management so admin rights are granted
temporarily and audited per request rather than always-on. I've noted
that in the main README as a next step rather than pretending the
current setup is the final answer.

## Why Terraform for the policy, PowerShell for the actions

Conditional Access policies are standing configuration — they should
exist consistently and be auditable over time, which is what Terraform
is built for (declarative, tracks state, detects drift). Device
assignment and admin provisioning are actions that happen in response to
an event, like a new device enrolling, which is a better fit for
PowerShell's procedural, step-by-step style. Using one tool for
everything would have been simpler to set up, but it would have meant
using the wrong tool for at least half the problem.

## Why a grace period on the compliance policy instead of an instant block

Blocking access the moment a device is flagged non-compliant sounds more
secure on paper, but in practice it generates a lot of avoidable support
tickets for short-lived, legitimate compliance drift (e.g. an antivirus
update mid-scan). A 24-hour grace period with a notification first keeps
the security outcome the same while giving the user a chance to self-
resolve before it becomes a blocked-access incident.
