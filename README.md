# Azure Language Centre

![Azure Language banner](./.github/assets/azure-language-banner.png)

Practical Python recipes for Azure AI Language, using `TextAnalysisClient` and
typed models from the `azure-ai-textanalytics` SDK in a
[Jupyter notebook](./notebook.ipynb), with detailed results and keyless authentication.

> [!IMPORTANT]
> **Stable service API, preview SDK, and non-retiring features**
>
> [requirements.txt](./requirements.txt) pins **`azure-ai-textanalytics==6.0.0b2`**.
> The notebook explicitly selects **`api_version="2025-11-01"`**, the newest
> stable service API documented for that published SDK. The **SDK package is
> preview**, but its default preview service API is not used. See the
> [SDK version support table](https://learn.microsoft.com/en-us/python/api/overview/azure/ai-textanalytics-readme?view=azure-python-preview).
> As of September 29, 2026, the service also has a newer GA API, `2026-05-01`,
> which is not in this SDK's documented supported versions; this repository
> targets the SDK rather than bypassing it with REST calls.
>
> Recipes for features announced for retirement have been removed:
>
> - [Entity linking](https://learn.microsoft.com/en-us/azure/ai-services/language-service/entity-linking/overview)
>   retires on **September 1, 2028**.
> - [Sentiment analysis and opinion mining](https://learn.microsoft.com/en-us/azure/ai-services/language-service/sentiment-opinion-mining/overview),
>   [key phrase extraction](https://learn.microsoft.com/en-us/azure/ai-services/language-service/key-phrase-extraction/overview),
>   [custom text classification](https://learn.microsoft.com/en-us/azure/ai-services/language-service/custom-text-classification/overview),
>   and [summarization](https://learn.microsoft.com/en-us/azure/ai-services/language-service/summarization/overview)
>   (extractive and abstractive) retire on **March 31, 2029**.
>
> Pinning an API version does not extend these services' lifetimes. For existing
> workloads that use those features, follow Microsoft's
> [migration guidance](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/transitioning-from-azure-language-features-to-foundry-models/4524092)
> for new projects and production workloads.

The notebook covers Microsoft's
[core capabilities](https://learn.microsoft.com/en-us/azure/ai-services/language-service/overview#core-capabilities):

- Language detection.
- Prebuilt named entity recognition (NER).
- Personally identifiable information (PII) detection and redaction.
- Text Analytics for health.
- Custom NER, using an existing trained deployment.
- Multi-action jobs combining NER and PII only.

## How to deploy

You need an Azure subscription, the [Azure Developer CLI (`azd`)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd),
and permission to create resource groups and Azure Language resources (for
example, the Contributor role on the subscription). Granting the notebook's
identity access also requires permission to assign Azure RBAC roles, such as
Owner or Role Based Access Control Administrator; Contributor alone cannot
assign roles.
The commands below use Bash on macOS, Linux, or Windows with WSL.

The [Bicep template](./infra/main.bicep) creates a resource group and an Azure
Language (`TextAnalytics`) resource on the Standard (`S`) tier, with a public
endpoint and a custom subdomain that supports Microsoft Entra ID authentication.
The notebook uses your local `azd` sign-in or an Azure host's managed identity,
rather than an API key.
The template currently also permits API-key authentication, but this workflow
does not use it. API calls can incur charges; use the calculator in
[Useful links](#useful-links) to estimate costs.

The included [azd project configuration](./azure.yaml) and
[Bicep parameter file](./infra/main.parameters.json) let you deploy with `azd up`.
This is an infrastructure-only deployment; it does not provision a notebook host.

1. Clone the repository and open its root directory, if you have not already:

   ```bash
   git clone https://github.com/NicoGrassetto/Azure-Language-Centre.git
   cd Azure-Language-Centre
   ```

2. Sign in with `azd` and create a named environment:

   ```bash
   azd auth login
   azd env new dev
   ```

3. Provision the Azure resources:

   ```bash
   azd up
   ```

   Select your Azure subscription and region when prompted.
   `azd` uses its Azure location picker, with Sweden Central highlighted as the
   recommended default. The picker is not filtered specifically for Azure
   Language, so check the
   [Azure Language regional support](https://learn.microsoft.com/azure/ai-services/language-service/concepts/regional-support)
   for the features you want to run and confirm available capacity. `azd` passes
   the environment name and selected location into the subscription-scoped
   Bicep deployment.

   Once deployment succeeds, `azd` saves the resource group, Language account
   name, and endpoint in the selected environment under `.azure/`, which is
   ignored by Git. There is no API key to retrieve for the keyless workflow.

4. Grant your signed-in identity access to the Language API:

   In the Azure portal, open the deployed Language resource, select
   **Access control (IAM)**, and add a role assignment for
   **Cognitive Services Language Reader** to the user or service principal you
   use with `azd auth login`. Ask an administrator to do this if you do not have
   role-assignment permissions. This is a one-time setup for each identity and
   Language resource, not something to repeat for every notebook run.

To deploy changes later, select the same environment with `azd env select dev`
and run `azd up` again. Keep the environment name, subscription, and region
unchanged to reuse the same resource names.

## How to run

Install Python 3.10 or newer with `venv` and `pip`, and complete the
deployment and role assignment above. Use a recent `azd` version that includes
`azd exec`. Run these commands locally from the repository root.

The notebook is already configured for keyless authentication. Local runs use
`AzureDeveloperCliCredential` and your `azd auth login` session by default.
There is no client cell to replace, API key to retrieve, or separate Azure CLI
login to perform.

1. Create and activate a virtual environment:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

   In a new terminal, run the activation command again; you do not need to
   recreate the environment.

2. Install the notebook dependencies and register a kernel inside the virtual
   environment:

   ```bash
   python -m pip install --upgrade pip
   python -m pip install -r requirements.txt
   python -m ipykernel install --sys-prefix \
     --name azure-language-centre \
     --display-name "Azure Language Centre (.venv)"
   ```

   The explicit SDK version pin installs the required 6.x models and methods;
   do not substitute the older 5.x `TextAnalyticsClient` package.

3. Select the deployed environment and start JupyterLab from the activated
   terminal. Replace `dev` if you chose a different environment name:

   ```bash
   azd env select dev
   azd exec -i -- jupyter lab notebook.ipynb
   ```

   `azd exec` injects the selected environment's endpoint and tenant ID into
   JupyterLab and its notebook kernels, so you do not need to export them
   yourself or load a `.env` file in the notebook.

   Open [notebook.ipynb](./notebook.ipynb), select the
   **Azure Language Centre (.venv)** kernel, and run **Creating the client** first.
   Then run the recipes you want to try, one cell at a time.

   The custom NER recipe is optional and requires an existing trained and deployed
   model. Before launching JupyterLab, configure it with:

   ```bash
   azd env set AZURE_LANGUAGE_CUSTOM_NER_PROJECT "<your-project-name>"
   azd env set AZURE_LANGUAGE_CUSTOM_NER_DEPLOYMENT "<your-deployment-name>"
   ```

   Otherwise, skip that cell rather than using **Run All**. The Bicep template
   does not create training storage, projects, or models. Custom NER remains
   supported; it is distinct from the retiring custom text classification
   features. Run **Closing the client and credential** last, and rerun the
   setup cell before trying more recipes afterward.

   Alternatively, use VS Code with its Python and Jupyter extensions. In the
   notebook's kernel picker, connect to the existing Jupyter server using the
   URL printed by JupyterLab, then select **Azure Language Centre (.venv)**.
   This uses the server already started with the `azd` environment.

   If your login expires, run `azd auth login` again using the identity granted
   access above. If an API call returns HTTP 403, verify the Language Reader
   role assignment and allow a few minutes for a new assignment to propagate.

4. When finished, stop JupyterLab with `Ctrl+C` and confirm shutdown if prompted,
   then deactivate the environment:

   ```bash
   deactivate
   ```

### Running with managed identity on Azure

The notebook also supports `ManagedIdentityCredential` without falling back to
a developer login. Managed identity must belong to the Azure compute host running
the notebook kernel, not to the Language account itself.

1. Enable a system-assigned identity on a compatible Azure host, or attach a
   user-assigned managed identity to it. The template in this repository does
   not create this host or its identity.
2. Grant that identity **Cognitive Services Language Reader** on the Language
   resource, using its principal/object ID for the role assignment.
3. Install [requirements.txt](./requirements.txt) in the host's notebook
   environment and configure these non-secret environment variables before
   starting the kernel:

   | Variable | Value |
   | --- | --- |
   | `AZURE_AUTH_MODE` | `managed_identity` |
   | `AZURE_LANGUAGE_ENDPOINT` | The deployed Language resource's custom-subdomain endpoint |
   | `AZURE_CLIENT_ID` | The **client ID** of a user-assigned managed identity; leave unset for a system-assigned identity |

   `AZURE_TENANT_ID`, `azd`, and interactive sign-in are not required for this
   mode. Set the optional custom NER project/deployment variables on the host
   too if you want to run that recipe.
4. Open the notebook in the host's configured Python kernel and run the setup
   cell before the recipes.

For local use, leave `AZURE_AUTH_MODE` unset or set it to `azd`. Managed identity
is not available on an ordinary local laptop. HTTP 403 errors require checking
the calling identity's role assignment and allowing time for RBAC propagation.

### Offline checks

After installing the dependencies, run:

```bash
python -m unittest discover -s tests -v
```

These tests exercise the notebook with the installed SDK and mocked HTTP/token
responses. They do not authenticate to Azure, deploy resources, or make service
calls.

## Useful links

- [Azure Language documentation on Microsoft Learn](https://learn.microsoft.com/en-us/azure/ai-services/language-service/overview)
- [Python Text Analysis SDK reference](https://learn.microsoft.com/en-us/python/api/azure-ai-textanalytics/azure.ai.textanalytics.textanalysisclient?view=azure-python-preview)
- [Azure Language Text Analysis service API reference, version 2025-11-01](https://learn.microsoft.com/en-us/rest/api/language/analyze-text/operation-groups?view=rest-language-analyze-text-2025-11-01&preserve-view=true)
- [Azure pricing calculator for Azure Language](https://azure.microsoft.com/en-us/pricing/calculator/?service=cognitive-services) - select Language and configure the region, features, and expected usage.

## Contributing and community

- [Contributing guidelines](./CONTRIBUTING.md) - proposing changes and validating recipes.
- [Code of conduct](./CODE_OF_CONDUCT.md) - community expectations and reporting concerns.
- [Security policy](./SECURITY.md) - supported code and private vulnerability reporting.

## License

This project is licensed under the [MIT License](./LICENSE).
