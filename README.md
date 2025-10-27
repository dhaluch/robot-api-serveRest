# robot-api-serveRest

Automação de testes de API com Robot Framework para o projeto Outsera.

## Descrição

Este repositório contém suíte de testes automatizados (Robot Framework) para a
API do projeto. O objetivo é executar as suítes, gerar relatórios (log.html,
report.html, output.xml) e disponibilizá-los como artifacts na execução do
GitHub Actions.

## Estrutura do projeto

Estrutura principal (raiz):

```
.
├── Json/
│   ├── atlz_usuario.json
│   └── usuario.json
├── resources/
│   ├── produto.robot
│   └── usuario.robot
├── tests/
│   └── API_Serverest.robot
├── report.html
├── log.html
├── output.xml
└── .github/
    └── workflows/
        └── robot-tests-pages.yml
```

- `Json/` - arquivos de dados/fixtures usados nos testes.
- `resources/` - recursos Robot (keywords, variáveis, bibliotecas locais).
- `tests/` - suítes Robot (.robot) a serem executadas.
- `report.html`, `log.html`, `output.xml` - exemplos/resultados locais gerados.
- `.github/workflows/robot-tests-pages.yml` - workflow do GitHub Actions que
  executa os testes e faz upload dos artifacts.

## Versões utilizadas

- Python: 3.11 (testado no workflow)
- Robot Framework: versão compatível instalada via pip (veja dependências)
- Runner GitHub Actions: ubuntu-latest (imagem usada no workflow)

Observação: caso precise de uma versão específica do Robot Framework, especifique
no `requirements.txt` e o workflow será facilmente ajustável.

## Dependências

Dependências mínimas (instalar localmente):

- Python 3.11+
- pip
- Robot Framework
- Robot Framework Requests (se a suíte usar a biblioteca Requests)

Instalação rápida (recomendado criar um virtualenv antes):

PowerShell (Windows):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install robotframework robotframework-requests
```

Linux / macOS:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install robotframework robotframework-requests
```

Se você preferir usar um `requirements.txt`, crie-o com as dependências e instale
com `pip install -r requirements.txt`.

## Como executar os testes localmente

1. Ative o virtualenv conforme mostrado acima.
2. Execute os testes da pasta `tests/` e gere os relatórios em `results/`:

PowerShell:

```powershell
mkdir results
robot --outputdir results tests
```

Linux / macOS:

```bash
mkdir -p results
robot --outputdir results tests
```

Após a execução, abra o relatório no Windows com:

```powershell
Start-Process .\results\report.html
```

Ou em Linux/macOS:

```bash
xdg-open results/report.html || open results/report.html
```

Se preferir que o job falhe quando houver falhas nos testes, execute sem `|| true`
no comando (o workflow padrão pode usar `|| true` para evitar que o job pare
automaticamente caso você prefira sempre gerar artifacts).

## Como executar via GitHub Actions

O workflow está configurado em `.github/workflows/robot-tests-pages.yml` e roda
por padrão nos eventos:

- push nas branches `main` e `feature/inicio`
- pull_request para `main`
- manualmente via `workflow_dispatch` (Run workflow)

O que o workflow faz:

1. Faz checkout do repositório.
2. Configura Python 3.11 e instala dependências.
3. Executa as suítes Robot da pasta `tests/` com saída em `results/`.
4. Faz upload dos arquivos gerados como artifact chamado `robot-results`.

Como consultar os relatórios no GitHub:

1. Acesse a aba `Actions` do repositório.
2. Selecione o run do workflow desejado.
3. Na página do run, desça até a seção `Artifacts` e clique em `robot-results`.
4. Baixe o ZIP e extraia: você encontrará `results/log.html`, `results/report.html` e `results/output.xml`.

Também é possível ver os logs do job clicando nos steps individuais no run.


