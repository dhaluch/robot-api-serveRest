*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           String
Library           OperatingSystem


*** Variables ***
*** Keywords ***
Criar Sessão
    [Documentation]    Cria a sessão HTTP 'api' (RequestsLibrary) com a URL base informada. Argumentos: ${URL} (ex.: https://serverest.dev). Pré-condição: nenhuma. Retorno: nenhum; a sessão 'api' fica disponível para os demais keywords.
    [Arguments]        ${URL}
    Create Session     alias=api     url=${URL}

Encerrar Sessão
    [Documentation]    Encerra todas as sessões HTTP abertas pela RequestsLibrary. Use ao final da suíte/execução. Não recebe argumentos e não retorna valores.
    Delete All Sessions



Cadastrar usuario
    [Documentation]    Cadastra um novo usuário com dados gerados via Faker. Status esperado: 201. Valida a mensagem 'Cadastro realizado com sucesso'. Pré-condição: sessão 'api' criada. Retorna: ${id}, ${nome}, ${email} do usuário criado.
    # Gera dados de usuário dinamicamente usando Faker (necessita pacote 'Faker' instalado)
    ${nome}            Evaluate                  __import__('faker').Faker().name()
    ${email}           Evaluate                  __import__('faker').Faker().email()
    ${senha}           Evaluate                  __import__('faker').Faker().password(length=10)
    ${administrador}   Set Variable             true
    ${body_dict}       Create Dictionary         nome=${nome}    email=${email}    password=${senha}    administrador=${administrador}

    ${header}          Create Dictionary         Content-Type=application/json

    ${response}        POST On Session           alias=api        url=/usuarios
    ...                headers=${header}
    ...                json=${body_dict}
    ...                expected_status=201
    Log To Console     ${response.json()}

    ${id}              Set Variable                ${response.json()['_id']}
    Dictionary Should Contain Value    ${response.json()}    Cadastro realizado com sucesso
    RETURN            ${id}    ${nome}    ${email}

    
Cadastrar usuario já cadastrado.
    [Documentation]    Tenta cadastrar um usuário com e-mail já existente. Status esperado: 400. Valida a mensagem 'Este email já está sendo usado'. Argumentos: ${nome_existente}, ${email_existente}. Pré-condição: já existir usuário com esse e-mail.
    [Arguments]        ${nome_existente}    ${email_existente}
    ${nome}            Set Variable             ${nome_existente}
    ${email}           Set Variable             ${email_existente}
    ${senha}           Evaluate                  __import__('faker').Faker().password(length=10)
    ${administrador}   Set Variable             true
    ${body_dict}       Create Dictionary         nome=${nome}    email=${email}    password=${senha}    administrador=${administrador}

    ${header}          Create Dictionary         Content-Type=application/json

    ${response}        POST On Session           alias=api        url=/usuarios
    ...                headers=${header}
    ...                json=${body_dict}
    ...                expected_status=400
    Log To Console     ${response.json()}
    Dictionary Should Contain Value    ${response.json()}    Este email já está sendo usado
    
Consulta usuarios Lista
    [Documentation]    Consulta a lista de usuários. Status esperado: 200. Asserta que 'quantidade' >= 0. Pré-condição: sessão 'api' criada. Não retorna dados (usa apenas asserções).
    ${header}         Create Dictionary          Content-Type=application/json
    ${response}        GET On Session             alias=api         url=/usuarios
    ...                expected_status=200
    Log To Console     ${response.json()}
    Should Be True     ${response.json()['quantidade']} >= 0


Consultar usuario por ID
    [Documentation]    Consulta um usuário específico pelo ID. Status esperado: 200. Asserta que o campo '_id' é igual a ${user_id}. Argumentos: ${user_id}.
    [Arguments]        ${user_id}
    ${header}         Create Dictionary          Content-Type=application/json
    ${response}        GET On Session             alias=api         url=/usuarios/${user_id}
    ...                expected_status=200
    Log To Console     ${response.json()}
    Should Be Equal    ${response.json()['_id']}    ${user_id}

Atualiza usuario por ID
    [Documentation]    Atualiza um usuário existente pelo ID. Status esperado: 200. Valida 'Registro alterado com sucesso'. Argumentos: ${user_id}. Pré-condição: ${user_id} deve existir.
    [Arguments]        ${user_id}
    ${nome}            Evaluate                  __import__('faker').Faker().name()
    ${email}           Evaluate                  __import__('faker').Faker().email()
    ${senha}           Evaluate                  __import__('faker').Faker().password(length=10)
    ${administrador}   Set Variable             true
    ${body_dict}       Create Dictionary         nome=${nome}    email=${email}    password=${senha}    administrador=${administrador}
    
    ${header}         Create Dictionary          Content-Type=application/json
    
    ${response}        PUT On Session             alias=api         url=/usuarios/${user_id}
    ...                headers=${header}         
    ...                json=${body_dict}   
    ...                expected_status=200
    Dictionary Should Contain Value    ${response.json()}    Registro alterado com sucesso

Atualiza usuario por ID(ID não encontrado)
    [Documentation]    Tenta atualizar usando um ID inexistente; a API cria um novo usuário. Status esperado: 201. Valida 'Cadastro realizado com sucesso'. Observação: comportamento específico da ServeRest.
    ${user_id}         Evaluate                  __import__('faker').Faker().uuid4()
    ${nome}            Evaluate                  __import__('faker').Faker().name()
    ${email}           Evaluate                  __import__('faker').Faker().email()
    ${senha}           Evaluate                  __import__('faker').Faker().password(length=10)
    ${administrador}   Set Variable              true
    ${body_dict}       Create Dictionary         nome=${nome}    email=${email}    password=${senha}    administrador=${administrador}
    
    ${header}         Create Dictionary          Content-Type=application/json
    
    ${response}        PUT On Session             alias=api         url=/usuarios/${user_id}
    ...                headers=${header}         
    ...                json=${body_dict}         
    ...                expected_status=201
    Dictionary Should Contain Value    ${response.json()}    Cadastro realizado com sucesso

Atualiza usuario por ID(ID não encontrado e e-mail já cadastrado)
    [Documentation]    Tenta atualizar (ID inexistente) com e-mail já cadastrado. Status esperado: 400. Valida 'Este email já está sendo usado'. Argumentos: ${email_existente}. Pré-condição: e-mail já cadastrado.
    [Arguments]        ${email_existente}
    ${user_id}         Evaluate                  __import__('faker').Faker().uuid4()
    ${nome}            Evaluate                  __import__('faker').Faker().name()
    ${email}           Set Variable              ${email_existente}
    ${senha}           Evaluate                  __import__('faker').Faker().password(length=10)
    ${administrador}   Set Variable              true
    ${body_dict}       Create Dictionary         nome=${nome}    email=${email}    password=${senha}    administrador=${administrador}
    
    ${header}         Create Dictionary          Content-Type=application/json
    
    ${response}        PUT On Session             alias=api         url=/usuarios/${user_id}
    ...                headers=${header}         
    ...                json=${body_dict}      
    ...                expected_status=400
    Dictionary Should Contain Value    ${response.json()}    Este email já está sendo usado
Delete usuario por ID
    [Documentation]    Deleta um usuário específico pelo ID. Status esperado: 200. Valida 'Registro excluído com sucesso'. Argumentos: ${user_id}. Pré-condição: ${user_id} deve existir.
    [Arguments]        ${user_id}
    ${header}         Create Dictionary          Content-Type=application/json
    ${response}        DELETE On Session          alias=api         url=/usuarios/${user_id}
    ...                expected_status=200
    Dictionary Should Contain Value    ${response.json()}    Registro excluído com sucesso