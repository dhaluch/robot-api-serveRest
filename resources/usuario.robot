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
    ${body}            Get File                  path=${EXECDIR}/Json/usuario.json
    
    ${header}         Create Dictionary          Content-Type=application/json
    
    ${response}        POST On Session            alias=api         url=/usuarios
    ...                headers=${header}         
    ...                data=${body}      
    ...                expected_status=201
    ${id}              Set Variable                ${response.json()['_id']}
    Dictionary Should Contain Value    ${response.json()}    Cadastro realizado com sucesso
    RETURN            ${id}
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
    ${body}            Get File                  path=${EXECDIR}/Json/atlz_usuario.json
    
    ${header}         Create Dictionary          Content-Type=application/json
    
    ${response}        PUT On Session             alias=api         url=/usuarios/${user_id}
    ...                headers=${header}         
    ...                data=${body}      
    ...                expected_status=200
    Dictionary Should Contain Value    ${response.json()}    Registro alterado com sucesso

Delete usuario por ID
    [Documentation]    Teste para deletar um usuário específico pelo ID
    [Arguments]        ${user_id}
    ${header}         Create Dictionary          Content-Type=application/json
    ${response}        DELETE On Session          alias=api         url=/usuarios/${user_id}
    ...                expected_status=200
    Dictionary Should Contain Value    ${response.json()}    Registro excluído com sucesso