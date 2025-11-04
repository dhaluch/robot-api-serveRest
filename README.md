# 🤖 Robot API - ServeRest (Outsera)

Automação de testes de API com Robot Framework para a API pública [ServeRest](https://serverest.dev/), com execução local e CI/CD no GitHub Actions, e publicação dos relatórios (report/log) no GitHub Pages.

[![Robot Tests & Pages](https://github.com/dhaluch/robot-api-serveRest/actions/workflows/robot-ci-pages.yml/badge.svg)](https://github.com/dhaluch/robot-api-serveRest/actions/workflows/robot-ci-pages.yml)

---

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias](#tecnologias)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Executando os Testes](#executando-os-testes)
- [Relatórios (Robot HTML)](#relatórios-robot-html)
- [CI/CD Pipeline](#cicd-pipeline)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Troubleshooting](#troubleshooting)
- [Contribuindo](#contribuindo)

---

## 🎯 Sobre o Projeto

Este projeto valida endpoints principais da ServeRest usando Robot Framework (RequestsLibrary), cobrindo:

- ✅ Criação de usuário (sucesso e e-mail já cadastrado)
- ✅ Consulta de usuários (lista e por ID)
- ✅ Atualização de usuário (ID existente e não encontrado)
- ✅ Exclusão de usuário

Geração de relatórios padrão do Robot Framework:
- 📄 `report.html` e `log.html`
- 🧾 `output.xml`

---

## 🛠️ Tecnologias

- **Robot Framework** (tests)
- **RequestsLibrary** (HTTP client)
- **Faker (Python)** (geração de dados dinâmicos)
- **GitHub Actions** (CI/CD)
- **GitHub Pages** (publicação de relatórios)

---

## 📋 Pré-requisitos

- **Python** 3.8+ (usamos 3.11 no CI)
- **pip**
- (Opcional) **virtualenv**

---

## 🚀 Instalação

PowerShell (Windows):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install robotframework robotframework-requests Faker
```

Linux/macOS:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install robotframework robotframework-requests Faker
```

Se preferir, crie um `requirements.txt`:

```txt
robotframework>=6.1.1
robotframework-requests>=0.9.7
Faker>=20.1.0
```

E instale com:

```bash
pip install -r requirements.txt
```

---

## ⚙️ Configuração

- Endpoints: utilizamos a API pública https://serverest.dev
- Dados dinâmicos: gerados via `Faker` nos keywords de `resources/usuario.robot`
- Sessão HTTP: criada em keywords com `Create Session` (RequestsLibrary)

> Dica: se precisar trocar a base URL, adicione uma variável `${BASE_URL}` em um recurso comum e use-a na criação da sessão.

---

## 🧪 Executando os Testes

Executar toda a suíte localmente e gerar relatórios em `results/`:

PowerShell:

```powershell
mkdir results
robot --outputdir results tests
Start-Process .\results\report.html
```

Linux/macOS:

```bash
mkdir -p results
robot --outputdir results tests
xdg-open results/report.html || open results/report.html
```

Executar apenas uma suíte:

```bash
robot --outputdir results tests/API_Serverest.robot
```

---

## 📊 Relatórios (Robot HTML)

- Após a execução, consulte:
  - `results/report.html`
  - `results/log.html`
  - `results/output.xml`
- No CI, os relatórios são publicados no GitHub Pages (branch `gh-pages`).
- URL esperada do Pages:

```
https://dhaluch.github.io/robot-api-serveRest/
```

> Observação: a publicação via Pages usa `peaceiris/actions-gh-pages@v3` e requer um secret `GH_PAGES_PAT` com scope `repo`.

---

## 🔄 CI/CD Pipeline

Workflow principal: `.github/workflows/robot-ci-pages.yml`

Disparos:
- ✅ Push para `main` e `feature/**`
- ✅ Pull Requests para `main`
- ✅ Execução manual (`workflow_dispatch`)

Etapas:
1. Checkout do código
2. Setup Python 3.11 e instalação de dependências
3. Execução do Robot (`robot --outputdir results tests`)
4. Preparação do diretório `site/` (cópia de `results/*`)
5. Deploy para `gh-pages` via `peaceiris/actions-gh-pages@v3`

Secrets necessários (para Pages via PAT):
- `GH_PAGES_PAT` – token (classic) com escopo `repo`

> Alternativa: se sua organização permitir `GITHUB_TOKEN` publicar em Pages, podemos voltar ao fluxo oficial, mas ele estava falhando por dependência transitiva de `upload-artifact@v3`.

---

## 📁 Estrutura do Projeto

```
robot-api-serveRest/
├── Json/
│   ├── atlz_usuario.json
│   └── usuario.json
├── resources/
│   ├── produto.robot
│   └── usuario.robot
├── tests/
│   └── API_Serverest.robot
├── results/                  # (gerado) saída dos testes
├── log.html                  # (exemplo/local)
├── report.html               # (exemplo/local)
├── output.xml                # (exemplo/local)
└── .github/
    └── workflows/
        ├── robot-ci-pages.yml        # workflow unificado (oficial)
        ├── robot-tests-pages.yml     # (obsoleto / aviso)
        └── publish-robot-pages.yml   # (obsoleto / aviso)
```

---

## 🔍 Troubleshooting

Para problemas comuns (CI, Pages, dependências, API), consulte o **[Guia de Troubleshooting](./TROUBLESHOOTING.md)**.

Alguns exemplos cobertos:
- ❌ Erro de ação `upload-artifact@v3` depreciada (como contornar)
- ❌ 403 ao publicar em `gh-pages` (PAT e permissões)
- ❌ `ModuleNotFoundError: faker`
- ❌ Falhas intermitentes com dados gerados (como estabilizar)
- ⏱️ Timeouts / problemas de rede com a ServeRest

---

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch: `git checkout -b feature/minha-feature`
3. Commit: `git commit -m "Add: minha nova feature"`
4. Push: `git push origin feature/minha-feature`
5. Abra um Pull Request

Padrões de commit sugeridos:
- `Add:` nova funcionalidade
- `Fix:` correção de bug
- `Update:` atualização de código existente
- `Refactor:` refatoração
- `Docs:` documentação
- `Test:` testes

---

## 📝 Scripts úteis (exemplos)

Sem makefile/script formal, use comandos diretos:

```powershell
# Criar venv e instalar deps (Windows)
python -m venv .venv; .\.venv\Scripts\Activate.ps1; python -m pip install --upgrade pip; pip install robotframework robotframework-requests Faker

# Rodar testes
robot --outputdir results tests
```

```bash
# Linux/macOS
python -m venv .venv && source .venv/bin/activate && python -m pip install --upgrade pip && pip install robotframework robotframework-requests Faker
robot --outputdir results tests
```

---

## 📄 Licença

Projeto com finalidade educacional/demonstrativa.

---

**Última atualização:** 2025-11-03