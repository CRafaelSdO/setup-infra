# 🚀 Setup Infra: Tunnel & Router

Este repositório contém a configuração automatizada da infraestrutura base para
uma VPS (ou ambiente local com WSL2). O objetivo é criar um
**ponto de entrada seguro** que permite o acesso remoto via SSH e o roteamento
de tráfego Web para múltiplos containers, sem a necessidade de abrir portas no
roteador (Port Forwarding).

## 🛠️ Arquitetura

A infraestrutura baseia-se em dois pilares principais rodando em Docker:

1. **Cloudflare Tunnel (`tunnel`)**: Cria uma ponte segura entre a rede da
   Cloudflare e o servidor. Ele gerencia o tráfego SSH (direcionando para o host
   via `host-gateway`) e o tráfego HTTP/HTTPS (direcionando para o Router).
2. **Nginx Proxy Manager (`router`)**: Atua como o cérebro do roteamento. Ele
   recebe as requisições do túnel e as distribui para as aplicações corretas
   baseadas nos subdomínios.

## 🏗️ Estrutura de Redes Docker

Para garantir o isolamento e a comunicação entre projetos, o setup cria duas redes:

- **`edge`**: Rede restrita para a comunicação entre o Túnel e o Proxy (`router`).
- **`routing`**: Rede global onde todas as futuras aplicações serão conectadas
  para serem expostas pelo Proxy.

## 📋 Pré-requisitos

- Docker e Docker Compose instalados.
- Usuário `deployer` criado no sistema (sem privilégios de sudo/wheel recomendado).
- Domínio configurado na Cloudflare.
- Um túnel criado no **Cloudflare Zero Trust** (Dashboard > Networks > Tunnels).

## 🚀 Passo a Passo para Utilização

### 1. Clonar o Repositório

Recomenda-se o clone na home do usuário `deployer`:

```bash
git clone https://github.com/CRafaelSdO/setup-infra.git
cd setup-infra
```

### 2. Configuração no Cloudflare Zero Trust

No painel do túnel no Cloudflare Dashboard, adicione os seguintes **Public Hostnames**:

| Subdomínio                  | Serviço (URL)                   | Descrição                         |
| --------------------------- | ------------------------------- | --------------------------------- |
| `ssh.seu-dominio.exemplo`   | `ssh://host.docker.internal:22` | Acesso SSH seguro ao Host         |
| `admin.seu-dominio.exemplo` | `http://router:81`              | Painel de Gestão do NPM           |
| `*.seu-dominio.exemplo`     | `http://router:80`              | Wildcard para todas as aplicações |

Recomendo primeiro configurar o ssh para ativar o túnel e depois configurar os outros subdomínios.

### 3. Executar o Setup

O script `setup.sh` automatiza a criação das redes e o deploy dos containers.
Execute passando o seu **Token do Túnel**:

```bash
./setup.sh SEU_CF_TUNNEL_TOKEN
```

### 4. Acessar o Painel

Após o script finalizar:

1. Acesse `admin.seu-dominio.exemplo`.
2. Credenciais padrão: `admin@example.com` / `changeme`.
3. Configure seus certificados SSL e as rotas (Proxy Hosts) para seus novos projetos.

## 🔒 Segurança

- **Zero Portas Abertas**: O firewall da sua máquina pode manter a porta 22
  bloqueada para conexões externas; o acesso ocorrerá apenas via túnel.
- **Usuário Limitado**: O usuário `deployer` gerencia os containers mas não
  possui acesso `wheel`, mitigando riscos de escape de container.
- **Isolamento de Rede**: Aplicações em containers não têm acesso direto à rede
  `edge`, apenas à `routing`, mantendo o túnel isolado.

## 📁 Estrutura de Arquivos

- **docker-compose.yml**: Definição dos serviços Tunnel e Router.
- **setup.sh**: Script de automação e criação de redes.
- **router/**: Dados persistentes do Proxy (gerado automaticamente).

---
