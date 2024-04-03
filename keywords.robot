*** Settings ***
Library     ApplicationLibrary.DesktopLibrary
Library     OperatingSystem
Library     Process

*** Variables ***

${app_path}                         ${CURDIR}\\esetlogcollector.exe
${ELC_logs_ZIPPED}                         ${CURDIR}\\ELC Logs.zip
${ELC_logs}                ${CURDIR}\\ELC Logs

${collect_button}                   xpath=//Button[@Name="Collect"]
${cancel_button}                    xpath=//Button[@Name="Cancel"]

${artifacts_to_collect_field}       xpath=//Text[@Name="Artifacts to collect"]
${log_age_field}                    xpath=//Text[@Name="Logs age limit [days]"]
${save_archive_as_field}            xpath=//Text[@Name="Save archive as"]
${save_archive_as_INPUT_FIELD}      xpath=//Edit[@ClassName="Edit"][@Name="Save archive as"]
${eset_logs_field}                  xpath=//Text[@Name="ESET logs collection mode"]

${operation_log}                    xpath=//Document[@ClassName="Edit"][@Name="Operation log"]

${popup}                            xpath=//Window[@Name="ESET Log Collector"]//Text[@ClassName="Static"]
${ok_button}                        xpath=//Window//Button[@Name="OK"]
${yes_button}                       xpath=//Window//Button[@Name="Yes"]

${collection_profile_dropdown}      xpath=//ComboBox[@ClassName="ComboBox"][@Name="Collection profile"]
@{list_items_collection_profile}    Default    Threat detection    All    None    Custom

${logs_age_dropdown}                xpath=//ComboBox[@ClassName="ComboBox"][@Name="Logs age limit [days]"]//Button[@Name="Open"]
@{list_items_logs_age}              1    5    30    60
${logs_age_selected_value}          xpath=//ComboBox[@ClassName="ComboBox"][@Name="Logs age limit [days]"]

${eset_logs_dropdown}               xpath=//ComboBox[@ClassName="ComboBox"][@Name="ESET logs collection mode"]
@{list_items_eset_logs}             Filtered binary    Original binary from disk

${no_eset_product_notification}     xpath=//Text[@ClassName="Static"][@Name="No supported ESET product detected."]

@{directories_for_default_profile}  \\Config  \\Windows  \\Windows\\Devices  \\Windows\\Logs  \\Windows\\TmpDirs 
@{files_for_default_profile}   \\collector_log.txt  \\metadata.txt  \\Config\\Network.txt  \\Config\\WinsockLSP.txt   \\Windows\\drives.txt   \\Windows\\Processes.txt  \\Windows\\ProcessesTree.txt  \\Windows\\Services.reg    \\Windows\\volumes.txt   


*** Keywords ***

Check Element is Visible
    [Arguments]    ${identifier}
    Element Should Be Visible    ${identifier}
    RETURN    ${True}

Check Element is Visible and Contains Text
    [Arguments]    ${identifier}    ${text}
    Check Element is Visible    ${identifier}
    ApplicationLibrary.DesktopLibrary.Element Text Should Be    ${identifier}    ${text}

Set Values
    [Arguments]    ${element}    ${value}
    Wait For And Clear Text    ${element}
    Send Keys To Element    ${element}    ${value}
    ApplicationLibrary.DesktopLibrary.Element Text Should Be    ${element}    ${value}

Select Item From ComboBox And Validate Selected
    [Arguments]    ${dropdown}    ${itemValue}    ${itemXpath}
    Select Element From ComboBox    ${dropdown}    ${itemXpath}    skip_to_desktop=${True}
    Check Element is Visible and Contains Text    ${dropdown}    ${itemValue}
    Log To Console  ${itemValue} selected with no issues
    Log   ${itemValue} selected with no issues

Select Item From DropDown and Validate Selected
    [Arguments]    ${dropdown}    ${dropdownValue}    ${itemXpath}    ${itemValue}
    Select Element From ComboBox    ${dropdown}    ${itemXpath}    skip_to_desktop=${True}
    Check Element is Visible and Contains Text    ${dropdownValue}    ${itemValue}
    Log To Console  ${itemValue} selected with no issues
    Log   ${itemValue} selected with no issues


Validate document contains text
    [Arguments]    ${file}    ${text}
    ${content}    OperatingSystem.Get File    ${ELC_logs}${file}
    Should Contain    ${content}    ${text}
    Log To Console    File: "${file}" contains text: "${text}"

Validate document exists and is not empty
    [Arguments]    ${file}
    File Should Exist    ${ELC_logs}${file}
    File Should Not Be Empty    ${ELC_logs}${file}

Validate directory exists and is not empty
    [Arguments]    ${directory}
    Directory Should Exist    ${directory}
    Directory Should Not Be Empty    ${directory}

Unzip folder
    [Arguments]    ${path}    ${destinationPath}
    Start Process
    ...    powershell
    ...    -Command
    ...    Expand-Archive -Path "${path}" -DestinationPath "${destinationPath}"
    ...    shell=${True}

Operation Log Should Contain Text
    [Arguments]    @{text_items}
    Wait Until Element Is Visible    ${operation_log}
    Log To Console    Operation Log contains:
    FOR    ${item}    IN    @{text_items}
        Element Should Contain Text    ${operation_log}    ${item}
        Log To Console    ${item}
    END

Start ESET Log Collector App
    Open Application
    ...    remote_url=http://127.0.0.1:4723
    ...    splash_delay=${0}
    ...    window_name=ESET Log Collector
    ...    app=${app_path}
    TRY
        Page Should Not Contain Element    ${popup}
    EXCEPT
        Element Should Contain Text    ${popup}    This application is currently not running under administrator
        Operation Log Should Contain Text    WARNING: Not running under administrator account.
    END
    Mouse Over And Click Element    ${yes_button}
    Wait Until Page Does Not Contain Element    ${yes_button}

Collect Logs
    [Setup]    Set Appium Timeout    500
    Check Element is Visible and Contains Text    ${collect_button}    Collect
    Set Values    ${save_archive_as_INPUT_FIELD}    ${ELC_logs_ZIPPED}
    Mouse Over And Click Element    ${collect_button}
    TRY
        Wait Until Page Contains Element    ${cancel_button}    timeout=5
    EXCEPT
        Mouse Over And Click Element    ${yes_button}
    END
    Wait Until Page Does Not Contain Element    ${cancel_button}
    Wait Until Page Contains Element    ${popup}
    Element Should Contain Text    ${popup}    Files have been collected and archived
    Element Should Be Visible    ${ok_button}
    Mouse Over And Click Element    ${ok_button}

Unzip Logs
    Wait Until Created    ${ELC_logs_ZIPPED}
    Unzip folder    ${ELC_logs_ZIPPED}    ${ELC_logs}
    Wait Until Created    ${ELC_logs}   timeout=60
    Log to Console    ${ELC_logs} exists