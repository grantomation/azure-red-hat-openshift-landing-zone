# To build locally
# podman build --build-arg GITHUB_RUNNER_VERSION=$(curl -s "https://api.github.com/repos/actions/runner/releases/latest" | jq -r .tag_name | sed 's/^v//') --build-arg HELM_VERSION=$(curl -s "https://api.github.com/repos/helm/helm/releases/latest" | jq -r .tag_name | sed 's/^v//') -t github_runner:local -f ./config_runner_container/Dockerfile .

FROM registry.access.redhat.com/ubi8-minimal:latest

ARG GITHUB_RUNNER_VERSION
ARG HELM_VERSION

ENV RUNNER_NAME ""
ENV PAT_GITHUB ""
ENV RUNNER_WORKDIR "_work"

LABEL name="github self-hosted runner for ARO configuration" \
      vendor="none" \
      version="1" \
      release="0" \
      summary="Github self-hosted runner" \
      description="Runs a github self-hosted runner for configuration commands from your private network"

RUN microdnf install vim lttng-ust libicu zlib krb5-libs openssl-libs wget tar gzip curl git jq which iputils bind-utils yum && mkdir /github

RUN wget https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz && \
    tar xvf actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz -C /github && \
    rm -f tar xvf actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz && \
    ./github/bin/installdependencies.sh 

RUN wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
tar xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz -C /bin linux-amd64/helm --strip-components 1 && \
rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz

RUN wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz && \
tar xvf oc.tar.gz -C /bin && \
rm -f /bin/README && \
rm -f oc.tar.gz

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
wget https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm && \
rpm --install packages-microsoft-prod.rpm && \
microdnf install azure-cli && \
rm -rf packages-microsoft-prod.rpm

COPY ./config_runner_container/runner_entrypoint.sh /github/runner_entrypoint.sh
RUN chmod +x /github/runner_entrypoint.sh

RUN cd /usr/bin && ln -s /usr/bin/vim vi

RUN chown -R 1001:0 /github && \
    chmod -R g=u /github

WORKDIR /github

ENV HOME=/github

USER 1001

ENTRYPOINT [ "/github/runner_entrypoint.sh" ]