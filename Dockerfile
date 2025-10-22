FROM jenkins/jenkins:2.528.1-lts-jdk21

USER root

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        lsb-release \
        python3 \
        python3-pip \
        curl \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Setup Docker repository
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
      "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.asc] \
      https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI
RUN apt-get update && apt-get install -y --no-install-recommends docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Add Jenkins user to docker group for socket access
RUN groupadd -f docker && usermod -aG docker jenkins


# Switch back to Jenkins user
USER jenkins

# Install Jenkins plugins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"

# Ensure Jenkins Docker Plugin uses local socket without TLS
ENV DOCKER_HOST=unix:///var/run/docker.sock
ENV DOCKER_TLS_VERIFY=
ENV DOCKER_CERT_PATH=
