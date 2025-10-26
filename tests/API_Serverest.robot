*** Settings ***

Library           RequestsLibrary
Library           Collections
Library           String
Library           OperatingSystem

Resource          ../resources/usuario.robot

Suite Setup       Criar Sessão       https://serverest.dev
Suite Teardown    Encerrar Sessão
*** Variables ***

*** Test Cases ***
Cadastrar usuario
    [Documentation]    Teste para cadastrar um novo usuário com sucesso
    ${body}            Get File                  path=${EXECDIR}/Json/usuario.json
    
    ${headers}         Create Dictionary          Content-Type=application/json
    
    ${response}        POST On Session            alias=api         url=/usuarios
    ...                headers=${headers}         
    ...                data=${body}      
    ...                expected_status=400
    #${id}              Set Variable                ${response.json()['_id']}
    Dictionary Should Contain Value    ${response.json()}    Este email já está sendo usado
