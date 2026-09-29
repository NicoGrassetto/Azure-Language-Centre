# Contributing

Contributions that improve Azure Language recipes, documentation, accessibility,
or deployment examples are welcome.

Please follow the [code of conduct](./CODE_OF_CONDUCT.md). For vulnerabilities,
use the [security policy](./SECURITY.md), not a public bug report.

## Bugs, questions, and proposals

Search the repository's
[issues](https://github.com/NicoGrassetto/Azure-Language-Centre/issues)
before opening a new one. Include the affected recipe, expected and actual
behavior, reproduction steps, and relevant SDK and service API versions.
Remove credentials, personal data, and subscription-specific details from logs.

For substantial changes, open an issue to discuss the approach before starting.
For Azure subscription, billing, or service incidents, use Azure support rather
than sharing account details in this repository.

## Making a change

1. Create a branch from the current default branch, using a fork if needed.
2. Follow the [README](./README.md) for deployment and notebook setup.
3. Keep the change focused and follow the surrounding code and documentation
   style.
4. Update the affected documentation, examples, and dependency declarations
   together. Explain changes to SDK versions or the pinned service API version.
5. Use synthetic sample data. Review notebook outputs and remove secrets,
   personal information, customer content, and environment-specific values
   before committing.

Do not commit local environment files, access tokens, API keys, or generated
deployment state. Do not include unrelated notebook metadata or output changes.

## Validating a change

- For notebook changes, run the client setup and affected cells with the intended
  kernel and dependencies. Do not use **Run All** unless every recipe's
  prerequisites, including custom Language projects, are configured.
- Azure calls can incur charges. Use resources you are authorized to test, avoid
  production data, and clean up test resources when finished.
- For infrastructure changes, compile the Bicep template and review the expected
  resource changes before deploying.
- For documentation changes, check formatting, relative links, and the accuracy
  of any commands you change.

## Opening a pull request

Explain what changed and why, link relevant issues, and describe the validation
you performed. State clearly which checks or Azure-dependent recipes you could
not run. Keep unrelated changes in separate pull requests.

Contributions are provided under this project's [MIT license](./LICENSE).
