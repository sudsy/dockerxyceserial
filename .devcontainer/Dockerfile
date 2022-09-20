
FROM debian:bullseye

RUN --mount=type=cache,target=/var/cache/apt apt update \
    && apt install -y curl gnupg2 lsb-release git

RUN curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list

RUN apt-get update \
    && apt-get install -y docker-ce-cli
