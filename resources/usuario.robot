*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           String
Library           OperatingSystem


*** Variables ***
*** Keywords ***
Criar Sessão
    [Arguments]        ${URL}
    Create Session     alias=api     url=${URL}

Encerrar Sessão
    Delete All Sessions



Cadastrar usuario
    [Documentation]    Teste para cadastrar um novo usuário com sucesso
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
    [Documentation]    Teste para validar o cadastro de um usuário com e-mail já existente
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
    [Documentation]    Teste para consultar a lista de usuários cadastrados
    ${header}         Create Dictionary          Content-Type=application/json
    ${response}        GET On Session             alias=api         url=/usuarios
    ...                expected_status=200
    Log To Console     ${response.json()}
    Should Be True     ${response.json()['quantidade']} >= 0


Consultar usuario por ID
    [Documentation]    Teste para consultar um usuário específico pelo ID
    [Arguments]        ${user_id}
    ${header}         Create Dictionary          Content-Type=application/json
    ${response}        GET On Session             alias=api         url=/usuarios/${user_id}
    ...                expected_status=200
    Log To Console     ${response.json()}
    Should Be Equal    ${response.json()['_id']}    ${user_id}

Atualiza usuario por ID
    [Documentation]    Teste para atualizar um usuário específico pelo ID
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
    [Documentation]    Tenta atualizar um usuário específico pelo ID não existente/cria um novo usuario
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
    [Documentation]    Tenta atualizar um usuário específico pelo ID não existente/tenta criar um novo usuario com e-mail já cadastrado
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
    [Documentation]    Teste para deletar um usuário específico pelo ID
    [Arguments]        ${user_id}
    ${header}         Create Dictionary          Content-Type=application/json
    ${response}        DELETE On Session          alias=api         url=/usuarios/${user_id}
    ...                expected_status=200
    Dictionary Should Contain Value    ${response.json()}    Registro excluído com sucesso