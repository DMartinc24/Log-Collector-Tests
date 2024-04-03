*** Settings ***
Library             ApplicationLibrary.DesktopLibrary
Library             OperatingSystem
Library             Process
Resource            keywords.robot

*** Test Cases ***

Check if Default Operation Log State is Correct
    [Documentation]  [Checks if Operation Log Contains Default Data]
    [Tags]  visual     
    Start ESET Log Collector App
    Operation Log Should Contain Text    ESET Log Collector    Copyright (c) 1992-2023 ESET, spol. s r.o. All rights reserved.
    ${no_eset_product_found}    Check Element is Visible    ${no_eset_product_notification}
    IF
    ...    ${no_eset_product_found} == ${True}
        Operation Log Should Contain Text    No supported ESET product detected.
    END


Check if Collect Button is Visible
    [Tags]   visual  
    Check Element is Visible    ${collect_button}

Check if Artifacts to Collect is Visible    
    [Tags]   visual     
    Check Element is Visible    ${artifacts_to_collect_field}

 Check if Save Archive as Input Field is Visible and Enabled   
    [Tags]   visual     
    Check Element is Visible    ${save_archive_as_field}
    Check Element is Visible    ${save_archive_as_INPUT_FIELD} 
    Element Should Be Enabled   ${save_archive_as_INPUT_FIELD}