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

Make a copy from the template file and adapt it (i.e. replace TODO-statements):

```bash
cp .env.template .env
```
Ensure the Azure account has the necessary permissions:

```bash
01_ensure_prerequisites.sh
```
## Create service

Finally run the following command to create the service:

```bash
02_create_service_with_prompt.sh
```

## License

See LICENSE.md

