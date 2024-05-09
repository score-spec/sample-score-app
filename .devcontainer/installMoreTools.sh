#!/bin/bash

mkdir install-more-tools
cd install-more-tools

SCORE_COMPOSE_VERSION=$(curl -sL https://api.github.com/repos/score-spec/score-compose/releases/latest | jq -r .tag_name)
wget https://github.com/score-spec/score-compose/releases/download/${SCORE_COMPOSE_VERSION}/score-compose_${SCORE_COMPOSE_VERSION}_linux_amd64.tar.gz
tar -xvf score-compose_${SCORE_COMPOSE_VERSION}_linux_amd64.tar.gz
sudo chmod +x score-compose
sudo mv score-compose /usr/local/bin

SCORE_HELM_VERSION=$(curl -sL https://api.github.com/repos/score-spec/score-helm/releases/latest | jq -r .tag_name)
wget https://github.com/score-spec/score-helm/releases/download/${SCORE_HELM_VERSION}/score-helm_${SCORE_HELM_VERSION}_linux_amd64.tar.gz
tar -xvf score-helm_${SCORE_HELM_VERSION}_linux_amd64.tar.gz
sudo chmod +x score-helm
sudo mv score-helm /usr/local/bin

KIND_VERSION=$(curl -sL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r .tag_name)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

cd ..
rm -rf install-more-tools