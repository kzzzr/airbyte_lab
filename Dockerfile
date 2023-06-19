ARG DBT_VERSION=1.0.0
FROM fishtownanalytics/dbt:${DBT_VERSION}

# Install utils
RUN apt -y update \
    && apt -y upgrade \
    && apt -y install curl wget gpg unzip

# Install dbt adapter
RUN set -ex \
    && python -m pip install --upgrade pip setuptools \
    && python -m pip install --upgrade dbt-clickhouse

# Install yc CLI
RUN curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | \
    bash -s -- -a

# Install Terraform
RUN curl -sL https://hashicorp-releases.yandexcloud.net/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && install -o root -g root -m 0755 terraform /usr/local/bin/terraform \
    && rm -rf terraform terraform.zip
    # Terraform configuration file ?
    # && cat <<EOF > ~/.terraformrc \n provider_installation { network_mirror { url = \"https://terraform-mirror.yandexcloud.net/\" include = [\"registry.terraform.io/*/*\"] } direct { exclude = [\"registry.terraform.io/*/*\"] } } \n EOF

ADD terraformrc ~/.terraformrc
RUN terraform init

ENV DBT_PROFILES_DIR=.