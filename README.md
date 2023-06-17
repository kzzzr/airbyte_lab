![image](https://github.com/SultankaReal/airbyte_lab/assets/77805226/991754f0-6452-4646-8b0d-46a776b29750)

![image](https://github.com/SultankaReal/airbyte_lab/assets/77805226/fc36275b-4e12-4bb0-8d2d-2471539f093b)

![image](https://github.com/SultankaReal/airbyte_lab/assets/77805226/16558d5c-7f54-42a6-8c37-fe4c86b137cd)


# Setting up Airbyte Data Pipelines Labs

- Configuring Data Pipelines with [Airbyte](https://airbyte.com/)
- Deploying Infrastructure as Code with [Terraform](https://www.terraform.io/) and [Yandex.Cloud](https://cloud.yandex.com/en-ru/)
- Instant development with [Github Codespaces](https://docs.github.com/en/codespaces)
- Assignment checks with [Github Actions](https://github.com/features/actions)

## Assignment TODO

⚠️ Attention! Always delete resources after you finish your work!

- [ ] [Fork this repository](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
- [ ] [Configure Developer Environment]()
- [ ] [Deploy Infrastructure to Yandex.Cloud with Terraform]()
    - [ ] VM with Airbyte installed
    - [ ] S3 Bucket
    - [ ] Clickhouse
- [ ] [Access Airbyte]()
- [ ] [Configure Data Pipelines]()
	- [ ] Postgres to Clickhouse
	- [ ] Postgres to S3
- [ ] [Create PR and make CI tests pass]()
    - [ ] Test assignment with Github Actions: Query files on S3 with Clickhouse S3 table engine
    
## 1. Configure Developer Environment

You have got several options to set up:
 
<details><summary>Start with GitHub Codespaces:</summary>
<p>

![GitHub Codespaces](./docs/github_codespaces.png)

</p>
</details>

<details><summary>Use devcontainer</summary>
<p>

Install devcontainer CLI

![](./docs/install_devcontainer_cli.png)

```bash
# build dev container
devcontainer build .

# open dev container
devcontainer open .
```

</p>
</details>


## 2. Deploy Infrastructure to Yandex.Cloud with Terraform

1. Get familiar with Yandex.Cloud web UI

    We will deploy:
    - [Yandex Compute Cloud](https://cloud.yandex.com/en/services/compute)
    - [Yandex Object Storage](https://cloud.yandex.com/en/services/storage)
    - [Yandex Managed Service for ClickHouse](https://cloud.yandex.com/en/services/managed-clickhouse)
    
    ![](./docs/clickhouse_management_console.gif)

1. Configure `yc` CLI: [Getting started with the command-line interface by Yandex Cloud](https://cloud.yandex.com/en/docs/cli/quickstart#install)

    ```bash
    yc init
    ```

1. Populate `.env` file

    `.env` is used to store secrets as environment variables.

    Copy template file [.env.template](./.env.template) to `.env` file:
    ```bash
    cp .env.template .env
    ```

    Open file in editor and set your own values.

    > ❗️ Never commit secrets to git    

1. Set environment variables:

    ```bash
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
    export TF_VAR_folder_id=$(yc config get folder-id)
    export $(xargs < .env)

    ## DEBUG
    # export TF_LOG_PATH=./terraform.log
    # export TF_LOG=trace
    ```

1. Deploy using Terraform

    Get familiar with Cloud Infrastructure: [main.tf](./main.tf) and [variables.tf](./variables.tf)

    ```bash
    terraform init
    terraform validate
    terraform fmt
    terraform plan
    terraform apply
    ```

    Store terraform output values as Environment Variables:

    ```bash
    export CLICKHOUSE_HOST=$(terraform output -raw clickhouse_host_fqdn)
    export DBT_HOST=${CLICKHOUSE_HOST}
    export DBT_USER=${CLICKHOUSE_USER}
    export DBT_PASSWORD=${TF_VAR_clickhouse_password}
    ```

    [EN] Reference: [Getting started with Terraform by Yandex Cloud](https://cloud.yandex.com/en/docs/tutorials/infrastructure-management/terraform-quickstart)
    
    [RU] Reference: [Начало работы с Terraform by Yandex Cloud](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart)

## 3. Access Airbyte

1. Get VM's public IP:

    ```bash
    terraform output -raw yandex_compute_instance_nat_ip_address
    ```

2. Lab's VM image already has Airbyte installed

    <details><summary>However if you'd like to do it yourself:</summary>
    <p>


    ```bash
    ssh airbyte@{yandex_compute_instance_nat_ip_address}

    sudo mkdir airbyte && cd airbyte
    sudo wget https://raw.githubusercontent.com/airbytehq/airbyte-platform/main/{.env,flags.yml,docker-compose.yaml}
    sudo docker-compose up -d
    ```

    </p>
    </details>

3. Access UI at {yandex_compute_instance_nat_ip_address}:8000

    With credentials:

    ```
    airbyte
    password
    ```

    ![Airbyte UI](./docs/airbyte_ui.png)

## 4. Configure Data Pipelines

1. Configure Postgres Source

    Get database credentials: https://github.com/kzzzr/mybi-dbt-showcase/blob/main/dbt_project.yml#L31-L36

    ❗️ Supply JDBC URL Parameter: `prepareThreshold=0`

    ![](./docs/airbyte_source_postgres.png)

1. Configure Clickhouse Destination

    ```bash
    terraform output -raw clickhouse_host_fqdn
    ```

    ![](./docs/airbyte_destination_clickhouse.png)

1. Configure S3 Destination

    Gather Object Storage Bucket name and a pair of keys:

    ```bash
    terraform output -raw yandex_storage_bucket_name
    terraform output -raw yandex_iam_service_account_static_access_key
    terraform output -raw yandex_iam_service_account_static_secret_key
    ```

    ❗️ Make sure you configure settings properly:
    
    - Set `s3_bucket_path` to `mybi`
    - Set endpoint to `storage.yandexcloud.net`

    ![](./docs/airbyte_destination_s3_1.png)

    ❗️ Set Destination Connector S3 version to `0.1.16`. Otherwise you will get errors with Yandex.Cloud Object Storage.

    ![](./docs/airbyte_destination_s3_3.png)

1. Sync data to Clickhouse Destination

    Only sync tables with `general_` prefix.

    ![](./docs/airbyte_sync_clickhouse_1.png)
    ![](./docs/airbyte_sync_clickhouse_2.png)
    ![](./docs/airbyte_sync_clickhouse_3.png)

1. Sync data to S3 Destination

    Only sync tables with `general_` prefix.

    ![](./docs/airbyte_sync_s3_1.png)
    ![](./docs/airbyte_sync_s3_2.png)
    ![](./docs/airbyte_sync_s3_3.png)

## 5. WIP Create PR and make CI tests pass

Since you have synced data to S3 bucket with public access, this data now should be available as Clickhouse External Table.

Set VARIABLE.

Let's make sure it works:

```bash
dbt debug
dbt test
```

If it works for you, open PR and see if CI tests pass.

![Github Actions check passed](./docs/github_checks_passed.png)

## Shut down your cluster

⚠️ Attention! Always delete resources after you finish your work!

![image](https://user-images.githubusercontent.com/34193409/214896888-3c6db293-8f1c-4931-8277-b2e4137f30a3.png)

```bash
terraform destroy
```
