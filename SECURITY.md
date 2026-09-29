# Security policy

## Scope and supported versions

This policy covers the code, notebooks, and deployment templates in Azure
Language Centre. Security fixes target the latest code on the default branch;
older commits and forks do not receive guaranteed backports.

These are learning samples, not a hardened production deployment. Review
authentication, permissions, network access, and data handling before adapting
them for production.

## Reporting a vulnerability

Do not disclose vulnerabilities in public issues, pull requests, or notebook
outputs. Never include live credentials, access tokens, or customer data in a
report.

Use GitHub's **Security > Advisories > Report a vulnerability** to
[submit a private report](https://github.com/NicoGrassetto/Azure-Language-Centre/security/advisories/new).
This option requires a repository administrator to
[enable private vulnerability reporting](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository).
Adding this policy does not enable that setting.

If private reporting is unavailable, open an
[issue](https://github.com/NicoGrassetto/Azure-Language-Centre/issues)
only to request a private reporting channel. Do not include vulnerability
details; wait until a private channel is established before sharing them.

In the private report, include:

- The affected file, recipe, and commit or version.
- A description of the impact and any required conditions.
- Minimal reproduction steps using synthetic data.
- Relevant dependency versions and sanitized logs.
- A suggested mitigation, if known.

Maintainers will assess the report and coordinate any fix and public disclosure
through the private channel. This community project does not guarantee response
or remediation times. Please coordinate publication of technical details with
the maintainers.

## Azure services and exposed credentials

For vulnerabilities in Microsoft's Azure services rather than this repository,
use the [Microsoft Security Response Center](https://msrc.microsoft.com/create-report).

If a credential has been exposed, revoke or rotate it immediately and review its
use. Removing it from a file or notebook output alone does not make it safe.
