#!/bin/bash

# Verifica se o token foi passado como argumento
if [ -z "$1" ]; then
    echo "Erro: O CF_TUNNEL_TOKEN não foi fornecido."
    echo "Uso: ./setup.sh <seu_token_aqui>"
    exit 1
fi

export CF_TUNNEL_TOKEN=$1

# Função para criar rede se não existir
create_network() {
    NET_NAME=$1

    if [ -z "$(docker network ls --filter name=^${NET_NAME}$ --format="{{.Name}}")" ]; then
        echo "Criando rede docker: ${NET_NAME}..."
        docker network create ${NET_NAME}
    else
        echo "Rede ${NET_NAME} já existe. Pulando..."
    fi
}

echo "--- Iniciando Setup de Infraestrutura ---"

# Criar as redes necessárias
create_network "edge"
create_network "routing"

echo "--- Subindo containers (Tunnel e NPM) ---"

# Sobe os containers usando o docker-compose
# O comando 'pull' garante que temos as versões mais recentes
docker compose pull
docker compose up -d

echo "--- Setup Finalizado com Sucesso ---"
