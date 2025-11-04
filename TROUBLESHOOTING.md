# Troubleshooting Guide - Robot Framework API Tests

Este guia ajuda a diagnosticar e resolver problemas comuns nos testes automatizados de API com Robot Framework.

---

## 📋 Índice

1. [Problemas na Pipeline (CI/CD)](#problemas-na-pipeline-cicd)
2. [Problemas com Robot Framework](#problemas-com-robot-framework)
3. [Problemas de API e Autenticação](#problemas-de-api-e-autenticação)
4. [Problemas com GitHub Pages](#problemas-com-github-pages)
5. [Problemas de Dependências](#problemas-de-dependências)
6. [Problemas Locais vs CI](#problemas-locais-vs-ci)

---

## 🔧 Problemas na Pipeline (CI/CD)

### Erro: `This request has been automatically failed because it uses a deprecated version of actions/upload-artifact: v3`

**Sintoma:**
```
Error: This request has been automatically failed because it uses a deprecated version of `actions/upload-artifact: v3`. 
Learn more: https://github.blog/changelog/2024-04-16-deprecation-notice-v3-of-the-artifact-actions/
```

**Causa:** O workflow está usando ações que transitivamente dependem de `actions/upload-artifact@v3`, que foi depreciado.

**Solução:**
O projeto já está configurado para usar `peaceiris/actions-gh-pages@v3` como alternativa. Certifique-se de que o Personal Access Token está configurado:

1. **Crie um Personal Access Token (PAT):**
   - Acesse: https://github.com/settings/tokens
   - Clique em "Generate new token (classic)"
   - Selecione o scope `repo`
   - Copie o token gerado

2. **Adicione como Secret no repositório:**
   - Vá em: `Settings > Secrets and variables > Actions`
   - Clique em "New repository secret"
   - Nome: `GH_PAGES_PAT`
   - Valor: Cole o token copiado

---

### Erro: `Permission denied to github-actions[bot]` ao publicar gh-pages

**Sintoma:**
```
remote: Permission to username/repo.git denied to github-actions[bot]
fatal: unable to access 'https://github.com/username/repo.git/': The requested URL returned error: 403
```

**Causa:** O `GITHUB_TOKEN` padrão não tem permissão para push no branch `gh-pages` ou o PAT não está configurado.

**Solução:**
1. Verifique se o secret `GH_PAGES_PAT` está configurado (ver seção anterior)
2. Certifique-se de que o PAT tem escopo `repo` completo
3. Verifique se o repositório permite Actions fazer deploy em Pages:
   - `Settings > Pages > Source` deve estar como "Deploy from a branch" 
   - Ou configure para "GitHub Actions" se preferir o fluxo oficial

---

### Workflow não executa em branches `feature/**`

**Sintoma:** Push para branch `feature/nova-funcionalidade` não aciona o workflow.

**Causa:** Configuração de triggers pode estar incorreta.

**Verificação:**
O arquivo `.github/workflows/robot-ci-pages.yml` deve conter:
```yaml
on:
  push:
    branches: [ main, 'feature/**' ]
```

**Solução:**
- Confirme que o nome da branch segue o padrão `feature/nome-da-funcionalidade`
- Verifique se há erros de sintaxe no arquivo YAML

---

## 🤖 Problemas com Robot Framework

### Erro: `ModuleNotFoundError: No module named 'faker'`

**Sintoma:**
```
FAIL : Evaluate    __import__('faker').Faker().name()
ModuleNotFoundError: No module named 'faker'
```

**Causa:** A biblioteca Faker não está instalada no ambiente.

**Solução:**
```bash
# Localmente
pip install Faker

# No CI, o workflow já inclui:
pip install robotframework robotframework-requests Faker
```

---

### Erro: `RequestException: Connection refused`

**Sintoma:**
```
RequestException: HTTPSConnectionPool(host='serverest.dev', port=443): 
Max retries exceeded with url: /usuarios (Caused by NewConnectionError)
```

**Causa:** Problemas de conectividade com a API ou API indisponível.

**Diagnóstico:**
1. Verifique se a API está funcionando:
   ```bash
   curl https://serverest.dev/usuarios
   ```

2. Teste a conectividade no CI verificando os logs do step "Run Robot Framework tests"

**Solução:**
- Se for problema temporário da API, execute o workflow novamente
- Se for problema de proxy/firewall no CI, pode ser necessário configurar proxy
- Adicione retry na configuração do RequestsLibrary se necessário


### Geradores Faker produzem dados inválidos

**Sintoma:** Testes falham esporadicamente com dados gerados pelo Faker.

**Causa:** Faker pode gerar emails ou nomes com caracteres especiais não aceitos pela API.

**Solução:**
```robot
# Para emails mais simples
${email}    Evaluate    f"user{__import__('random').randint(1000,9999)}@test.com"

# Para nomes simples
${nome}     Evaluate    f"User {__import__('random').randint(1000,9999)}"

# Manter senha aleatória
${senha}    Evaluate    __import__('faker').Faker().password(length=10)
```

---

## 🌐 Problemas de API e Autenticação

### Erro 401: Unauthorized em endpoints protegidos

**Sintoma:**
```
HTTPError: 401 Client Error: Unauthorized for url: https://serverest.dev/produtos
```

**Causa:** Token de autenticação ausente ou inválido.

**Solução:**
1. Implemente login e captura de token:
   ```robot
   *** Keywords ***
   Fazer Login E Obter Token
       ${login_data}    Create Dictionary    email=admin@test.com    password=teste123
       ${response}      POST On Session    alias=api    url=/login    json=${login_data}
       ${token}         Set Variable       ${response.json()['authorization']}
       RETURN          ${token}
   ```

2. Use o token nos headers:
   ```robot
   ${token}     Fazer Login E Obter Token
   ${headers}   Create Dictionary    Authorization=${token}    Content-Type=application/json
   ${response}  GET On Session    alias=api    url=/produtos    headers=${headers}
   ```

---

### Erro 429: Too Many Requests

**Sintoma:**
```
HTTPError: 429 Client Error: Too Many Requests for url: https://serverest.dev/usuarios
```

**Causa:** API tem rate limiting e muitas requisições foram feitas.

**Solução:**
1. Adicione delays entre requisições:
   ```robot
   Sleep    1s    # Aguarda 1 segundo entre requisições
   ```

2. Implemente retry com backoff:
   ```robot
   Wait Until Keyword Succeeds    3x    2s    Cadastrar usuario
   ```
---

## 📄 Problemas com GitHub Pages

### Relatório não é publicado no GitHub Pages

**Sintoma:** Pipeline executa com sucesso mas não há relatório disponível na URL do Pages.

**Diagnóstico:**
1. Verifique se o Pages está habilitado:
   - `Settings > Pages > Source` deve estar configurado
   
2. Verifique se os arquivos foram gerados:
   - Nos logs do workflow, procure por "ls -la site"
   - Deve mostrar `report.html` e `log.html`

**Solução:**
```bash
# Verifique localmente se os testes geram os arquivos
robot --outputdir results tests/
ls results/
# Deve conter: output.xml, report.html, log.html
```

---

### Página do GitHub Pages mostra "404"

**Sintoma:** URL do Pages abre mas mostra página não encontrada.

**Causa:** Arquivo `index.html` não foi criado ou está mal formado.

**Solução:**
O workflow já está configurado para criar um `index.html` básico. Verifique se o step "Prepare site folder for Pages" executou com sucesso nos logs.

---

### CSS/JS não carregam no relatório

**Sintoma:** Relatório aparece sem formatação ou funcionalidades JavaScript.

**Causa:** Caminhos relativos podem estar quebrados no GitHub Pages.

**Solução:**
Robot Framework gera relatórios auto-contidos, mas verifique se não há bloqueios de CORS ou CSP. O problema é raro com relatórios do Robot Framework.

---

## 📦 Problemas de Dependências

### Erro: `robot: command not found`

**Sintoma:**
```bash
bash: robot: command not found
```

**Causa:** Robot Framework não está instalado no ambiente.

**Solução:**
```bash
# Localmente
pip install robotframework robotframework-requests

# Verifique a instalação
robot --version

# No CI, o workflow já inclui a instalação
```

---

### Versão do Python incompatível

**Sintoma:**
```
ERROR: robotframework requires Python '>=3.8' but the running Python is 3.7.x
```

**Solução:**
O workflow está configurado para Python 3.11. Se executar localmente:
```bash
# Verifique sua versão
python --version

# Instale Python 3.8+ se necessário
# Use pyenv, conda, ou instale diretamente
```

---

### Conflitos de dependências

**Sintoma:**
```
pip._vendor.resolvelib.resolvers.ResolutionImpossible: Could not find a version that satisfies all requirements
```

**Solução:**
1. Use ambientes virtuais:
   ```bash
   python -m venv venv
   # Windows:
   venv\Scripts\activate
   # Linux/Mac:
   source venv/bin/activate
   
   pip install -r requirements.txt
   ```

2. Crie `requirements.txt` se não existir:
   ```txt
   robotframework>=6.1.1
   robotframework-requests>=0.9.7
   Faker>=20.1.0
   ```

---

## 🔄 Problemas Locais vs CI

### Testes passam localmente mas falham no CI

**Causas comuns:**

1. **Diferenças de ambiente:**
   ```robot
   # Adicione logs para debug
   Log To Console    Python version: ${EXECDIR}
   Log To Console    Current working directory: ${CURDIR}
   ```

2. **Timing diferentes:**
   ```robot
   # Adicione waits se necessário
   Sleep    2s    # CI pode ser mais lento
   ```

3. **Conectividade de rede:**
   - CI pode ter restrições de rede diferentes do ambiente local

**Diagnóstico:**
1. Compare logs locais vs CI
2. Verifique se todas as dependências estão sendo instaladas no CI
3. Adicione mais logging nos testes para identificar onde falha

---

### Variáveis de ambiente diferentes

**Sintoma:** Testes usam configurações diferentes localmente vs CI.

**Solução:**
```robot
*** Variables ***
${BASE_URL}    https://serverest.dev
${TIMEOUT}     30s

*** Keywords ***
Setup Test Environment
    # Configure baseado no ambiente
    ${env}    Get Environment Variable    CI    default=false
    Run Keyword If    '${env}' == 'true'    Set Suite Variable    ${TIMEOUT}    60s
```

---

## 🆘 Como Obter Mais Informações para Debug

### 1. Habilite logs detalhados no Robot Framework

```robot
*** Settings ***
Library    RequestsLibrary    debug=3    # Habilita logs HTTP detalhados

*** Test Cases ***
Debug Test
    Log To Console    Starting test with debug info
    ${response}    GET On Session    alias=api    url=/usuarios
    Log    Response: ${response.text}
    Log    Headers: ${response.headers}
    Log    Status: ${response.status_code}
```

### 2. Use o Robot Framework log.html para análise detalhada

```bash
# Após executar os testes, abra o log detalhado
robot --outputdir results tests/
# Abra results/log.html no navegador para ver logs detalhados
```

### 3. Capture informações do ambiente

```robot
*** Keywords ***
Log Environment Info
    ${python_version}    Evaluate    sys.version    sys
    ${platform_info}     Evaluate    platform.platform()    platform
    Log To Console    Python: ${python_version}
    Log To Console    Platform: ${platform_info}
```

### 4. Use variáveis de debug

```robot
*** Variables ***
${DEBUG}    ${FALSE}

*** Keywords ***
Debug Log
    [Arguments]    ${message}
    Run Keyword If    ${DEBUG}    Log To Console    DEBUG: ${message}
```

---

## 🔍 Analisando Falhas Específicas

### RequestsLibrary falhas

```robot
*** Keywords ***
Safe API Call
    [Arguments]    ${method}    ${url}    ${expected_status}=200    &{kwargs}
    ${response}    Run Keyword And Return Status
    ...    Run Keyword    ${method} On Session    alias=api    url=${url}    expected_status=${expected_status}    &{kwargs}
    Run Keyword If    not ${response}    Log    API call failed for ${method} ${url}
    RETURN    ${response}
```

### Validação de dados mais robusta

```robot
*** Keywords ***
Validate Response Contains
    [Arguments]    ${response}    ${expected_value}    ${key}=message
    ${response_dict}    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${response_dict}    ${key}
    Should Contain    ${response_dict}[${key}]    ${expected_value}
```

---

## 📞 Precisa de Ajuda?

Se o problema persistir após seguir este guia:

1. **Verifique os logs completos** da pipeline no GitHub Actions
2. **Analise o relatório Robot Framework** publicado no gh-pages (log.html)
3. **Compare** o comportamento local vs CI usando os logs detalhados
4. **Revise** as respostas da API - elas podem ter mudado
5. **Teste manualmente** os endpoints da API com curl ou Postman

---

## 📚 Links Úteis

- [Robot Framework Documentation](https://robotframework.org/robotframework/)
- [RequestsLibrary Documentation](https://marketsquare.github.io/robotframework-requests/)
- [ServeRest API Documentation](https://serverest.dev/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Faker Documentation](https://faker.readthedocs.io/)

---

## 📋 Checklist de Verificação Rápida

Antes de reportar um problema, verifique:

- [ ] ✅ Python 3.8+ instalado
- [ ] ✅ Dependências instaladas: `pip install robotframework robotframework-requests Faker`
- [ ] ✅ API ServeRest está acessível: `curl https://serverest.dev/usuarios`
- [ ] ✅ Secrets configurados no GitHub (se usar CI): `GH_PAGES_PAT`
- [ ] ✅ GitHub Pages habilitado no repositório
- [ ] ✅ Workflow executa na branch correta (main ou feature/**)
- [ ] ✅ Logs detalhados analisados (log.html local ou logs do CI)

---

**Última atualização:** 2025-11-03