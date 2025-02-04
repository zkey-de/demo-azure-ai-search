# AI-enabled search service with Microsoft Azure

This repository contains bash scripts for building an AI-powered search service using Microsoft Azure using Azure CLI and Azure REST-Api. 

## Overview
- [Preparations](#preparations)
- [Create service](#create-service)
- [License](#license)

## Preparations

### Clone repository

```bash
git clone https://github.com/zkey-de/demo-azure-ai-search.git
```

### Authenticate to Azure portal

```bash
az login
```

### Prepare the environment file

Create a `.env` file from the provided template file `.env.template` and update it with your specific configuration (e.g., replace TODO placeholders with actual values):

```bash
cp .env.template .env
```
Run the following script to verify that your Azure account has the required permissions:

```bash
bash 01_ensure_prerequisites.sh
```
## Create service

Finally run the following command to create the service:

```bash
bash 02_create_service_with_prompt.sh
```

## License

See LICENSE.md

