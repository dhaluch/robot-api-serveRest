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
Usuario - Cadastrar Usuario
        ${id}    ${nome}    ${email}    Cadastrar usuario
        Delete usuario por ID           ${id}
Usuario - Cadastrar Usuario existente
        ${id}    ${nome}    ${email}    Cadastrar usuario
        Cadastrar usuario já cadastrado.    ${nome}    ${email}
        Delete usuario por ID           ${id}
Usuario - Consultar lista de usuarios
        Consulta usuarios Lista
Usuario - Consultar usuario por ID inexistente
        ${id}    ${nome}    ${email}    Cadastrar usuario
        Consultar usuario por ID        ${id}
        Delete usuario por ID           ${id}
Usuario - Atualizar usuario por ID inexsistente/Cria novo usuario
        Atualiza usuario por ID(ID não encontrado) 
Usuario - Atualizar usuario por ID inexsistente/e-mail já cadastrado
        ${id}    ${nome}    ${email}    Cadastrar usuario
        Atualiza usuario por ID(ID não encontrado e e-mail já cadastrado)    ${email}
Usuario - Deletar usuario por ID
        ${id}    ${nome}    ${email}    Cadastrar usuario
        Delete usuario por ID           ${id}