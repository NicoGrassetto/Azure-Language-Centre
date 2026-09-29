# Azure Language Centre

![Azure Language banner](./.github/assets/azure-language-banner.png)

Practical Python recipes for Azure AI Language, demonstrating the
`azure-ai-textanalytics` SDK in a [Jupyter notebook](./notebook.ipynb) with realistic
examples and detailed result output.

## How to deploy

You need an Azure subscription, the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli),
and permission to create resource groups and Azure Language resources and retrieve
their keys (for example, the Contributor role on the subscription).
The commands below use Bash on macOS, Linux, or Windows with WSL.

The [Bicep template](./infra/main.bicep) creates a resource group and an Azure
Language (`TextAnalytics`) resource on the Standard (`S`) tier, with a public
endpoint and API-key authentication. API calls can incur charges; use the
calculator in [Useful links](#useful-links) to estimate costs.

1. Clone the repository and open its root directory, if you have not already:

   ```bash
   git clone https://github.com/NicoGrassetto/Azure-Language-Centre.git
   cd Azure-Language-Centre
   ```

2. Sign in, select your subscription, install the Bicep CLI, and register the
   resource provider:

   ```bash
   az login
   az account set --subscription "<subscription-id>"
   az bicep install
   az provider register --namespace Microsoft.CognitiveServices --wait
   ```

3. Deploy the infrastructure at subscription scope:

   ```bash
   ENVIRONMENT_NAME="dev"
   AZURE_LOCATION="swedencentral"
   DEPLOYMENT_NAME="language-${ENVIRONMENT_NAME}-${AZURE_LOCATION}"

   az deployment sub create \
     --name "$DEPLOYMENT_NAME" \
     --location "$AZURE_LOCATION" \
     --template-file infra/main.bicep \
     --parameters environmentName="$ENVIRONMENT_NAME" location="$AZURE_LOCATION"
   ```

   The template accepts `swedencentral`, `eastus`, `westeurope`, or `northeurope`.
   Check that your chosen region supports the features you want to run and has
   available capacity. Keep the environment name and region unchanged when
   redeploying to reuse the same resource names.

   Once deployment succeeds, its outputs include the resource group, Language
   account name, and endpoint. The API key is retrieved separately in the next
   section; it is not exposed as a deployment output.

## How to run

Install a recent Python 3 version with `venv` and `pip`, and complete the deployment
above. Run these commands locally from the repository root, using the same Azure
subscription as the deployment.

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
   python -m pip install "azure-ai-textanalytics>=5.3,<6" jupyterlab ipykernel
   python -m ipykernel install --sys-prefix \
     --name azure-language-centre \
     --display-name "Azure Language Centre (.venv)"
   ```

   The SDK is kept on the 5.x line because the notebook uses `TextAnalyticsClient`
   with service API version `2023-04-01`.

3. Load the endpoint and API key into the current terminal's environment. Adjust
   the deployment name if you changed the values in the deployment example:

   ```bash
   DEPLOYMENT_NAME="language-dev-swedencentral"

   AZURE_RESOURCE_GROUP="$(az deployment sub show \
     --name "$DEPLOYMENT_NAME" \
     --query properties.outputs.AZURE_RESOURCE_GROUP.value --output tsv)"
   AZURE_LANGUAGE_NAME="$(az deployment sub show \
     --name "$DEPLOYMENT_NAME" \
     --query properties.outputs.AZURE_LANGUAGE_NAME.value --output tsv)"
   AZURE_LANGUAGE_ENDPOINT="$(az deployment sub show \
     --name "$DEPLOYMENT_NAME" \
     --query properties.outputs.AZURE_LANGUAGE_ENDPOINT.value --output tsv)"
   AZURE_LANGUAGE_KEY="$(az cognitiveservices account keys list \
     --resource-group "$AZURE_RESOURCE_GROUP" \
     --name "$AZURE_LANGUAGE_NAME" \
     --query key1 --output tsv)"

   export AZURE_LANGUAGE_ENDPOINT AZURE_LANGUAGE_KEY
   ```

   These variables must be present in the notebook kernel's environment. The
   notebook does not load a `.env` file automatically. Do not paste API keys into
   notebook cells, print them, or commit them to source control.

4. Start JupyterLab from this same activated terminal:

   ```bash
   jupyter lab notebook.ipynb
   ```

   Open [notebook.ipynb](./notebook.ipynb), select the
   **Azure Language Centre (.venv)** kernel, and run **Creating the client** first.
   Then run the recipes you want to try, one cell at a time.

   The custom single-label/multi-label classification and custom entity
   recognition recipes require separately trained and deployed Language
   projects. Replace `<your-project-name>` and `<your-deployment-name>` in those
   cells, or skip them. The Bicep template does not create those projects, models,
   or their training storage, so do not use **Run All** on the unchanged notebook.
   Run **Closing the client** last; rerun the client setup cell before trying
   more recipes afterward.

   Alternatively, use VS Code with its Python and Jupyter extensions. Start
   VS Code from the configured terminal with `code .` and select the `.venv`
   interpreter through **Select Kernel**. If VS Code was already running, fully
   restart it from that terminal so it inherits the exported variables.

5. When finished, stop JupyterLab with `Ctrl+C` and confirm shutdown if prompted,
   then clear the credentials and deactivate the environment:

   ```bash
   unset AZURE_LANGUAGE_ENDPOINT AZURE_LANGUAGE_KEY
   deactivate
   ```

## Useful links

- [Azure Language documentation on Microsoft Learn](https://learn.microsoft.com/en-us/azure/ai-services/language-service/overview)
- [Azure Language Text Analysis REST API reference, version 2023-04-01](https://learn.microsoft.com/en-us/rest/api/language/analyze-text/operation-groups?view=rest-language-analyze-text-2023-04-01&preserve-view=true)
- [Azure pricing calculator for Azure Language](https://azure.microsoft.com/en-us/pricing/calculator/?service=cognitive-services) - select Language and configure the region, features, and expected usage.

## License

This project is licensed under the [MIT License](./LICENSE).
