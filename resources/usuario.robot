*** Settings ***
Library           RequestsLibrary

*** Variables ***
*** Keywords ***
Criar Sessão
    [Arguments]        ${URL}
    Create Session     alias=api     url=${URL}

Encerrar Sessão
    Delete All Sessions

