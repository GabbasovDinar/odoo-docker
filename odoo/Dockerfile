#------------------------#
#     Odoo Community     #
#------------------------#

ARG ODOO_TAG
FROM odoo:${ODOO_TAG}

# Switch to root user
USER root

# Receive ARGs from docker-compose.yml & convert them into ENVs
ARG ODOO_TAG
ARG ROOT_PATH
ARG LOG_PATH
ARG ENTERPRISE_ADDONS
ARG ENTERPRISE_REPO_URL
ARG GITHUB_ACCESS_TOKEN
ARG THIRD_PARTY_ADDONS
ARG ODOO_RC
ARG USE_REDIS
ARG USE_S3
ARG USE_ODOO_ENTERPRISE
ARG USE_SENTRY

ENV ODOO_TAG=${ODOO_TAG} \
    LOG_PATH=${LOG_PATH} \
    ENTERPRISE_ADDONS=${ENTERPRISE_ADDONS} \
    GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN} \
    THIRD_PARTY_ADDONS=${THIRD_PARTY_ADDONS} \
    ODOO_RC=${ODOO_RC} \
    USE_REDIS=${USE_REDIS} \
    USE_S3=${USE_S3} \
    USE_ODOO_ENTERPRISE=${USE_ODOO_ENTERPRISE} \
    ENTERPRISE_REPO_URL=${ENTERPRISE_REPO_URL} \
    USE_SENTRY=${USE_SENTRY}

#---------------------#
#       Logging       #
#---------------------#
# Create odoo.log file
RUN touch ${LOG_PATH} && chown odoo:odoo ${LOG_PATH}

#------------------------#
#    APT Dependencies    #
#------------------------#
# Install Odoocker image dependencies
RUN apt-get update && apt-get install -y \
    # `zip` and `unzip` for filestore management
    zip \
    unzip \
    # `git` required packages
    git \
    git-man \
    less \
    libcbor0 \
    libcurl3-gnutls \
    libedit2 \
    liberror-perl \
    libfido2-1 \
    libxmuu1 \
    openssh-client \
    patch \
    xauth \
    wget \
    && wget https://github.com/mikefarah/yq/releases/download/v4.33.3/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    # Remove apt lists
    rm -rf /var/lib/apt/lists/*

#------------------------#
#   Configure Git Auth   #
#------------------------#
# Add GitHub token to git config
RUN git config --global url."https://x-access-token:${GITHUB_ACCESS_TOKEN}@github.com/".insteadOf "https://github.com/"

#---------------------#
#   PIP Dependecies   #
#---------------------#
COPY --chown=odoo:odoo ./odoo/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt

#------------------------#
#  Clone Repositories    #
#------------------------#
RUN mkdir -p ${THIRD_PARTY_ADDONS} && mkdir -p ${ENTERPRISE_ADDONS}

COPY --chown=odoo:odoo ./odoo/clone_enterprise.sh /
RUN chmod +x /clone_enterprise.sh
RUN /clone_enterprise.sh

COPY --chown=odoo:odoo ./odoo/clone_third_party_addons.sh /
RUN chmod +x /clone_third_party_addons.sh
COPY --chown=odoo:odoo ./odoo/third-party-addons.yml /
RUN /clone_third_party_addons.sh

#-----------------------#
#       Odoo Conf       #
#-----------------------#
# Copy environment variables & script to generate odoo.conf
COPY --chown=odoo:odoo ./.env /
COPY --chown=odoo:odoo ./odoo/odoo.conf /
COPY --chown=odoo:odoo ./odoo/odoorc.sh /

# Generate odoo.conf
RUN /odoorc.sh && chown odoo:odoo ${ODOO_RC}

# Switch back to odoo user
USER odoo
