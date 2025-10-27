*** Settings ***

Library           RequestsLibrary
Library           Collections
Library           String
Library           OperatingSystem

Resource          ../resources/usuario.robot
Resource          ../resources/produto.robot

Suite Setup       Criar Sessão       https://serverest.dev
Suite Teardown    Encerrar Sessão
*** Variables ***

*** Test Cases ***
CRUD Usuario - Cadastrar Usuario
        ${id}    Cadastrar usuario
        Consulta usuarios Lista
        Consultar usuario por ID        ${id}
        Atualiza usuario por ID         ${id}
        Delete usuario por ID           ${id}