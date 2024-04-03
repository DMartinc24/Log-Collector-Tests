*** Settings ***
Library     ApplicationLibrary.DesktopLibrary
Library     OperatingSystem
Library     Process
Resource    keywords.robot


*** Test Cases ***
Collect Logs Under "None" Profile Should Trigger Popup "No artifacts are selected"
    [Documentation]  [Checks that None Profile Cannot Create Logs]
    [Tags]    functional-none
    Start ESET Log Collector App
    Select Item From ComboBox And Validate Selected
    ...    ${collection_profile_dropdown}
    ...    None
    ...    xpath=//ListItem[@Name="None"]
    Check Element is Visible and Contains Text    ${collect_button}    Collect
    Mouse Over And Click Element    ${collect_button}
    Element Should Be Visible    ${popup}
    Element Should Contain Text    ${popup}    No artifacts are selected
    Mouse Over And Click Element    ${ok_button}

 Collect Logs Under "Default" Profile Should Create ELC Logs
    [Documentation] [Checks that Default Profile Can Create Logs]
    [Tags]    functional-default
    Start ESET Log Collector App
    Check Element is Visible and Contains Text    ${collection_profile_dropdown}    Default
    Collect Logs
    Unzip Logs

 ELC Logs for "Default" Profile Should Contain Required Files and Folders
    [Documentation] [Checks that Default Profile Created Logs Have Correct Files and Folders]
    [Tags]    functional-default
    Validate directory exists and is not empty    ${ELC_logs}
    FOR    ${directory}    IN    @{directories_for_default_profile}
        Validate directory exists and is not empty    ${ELC_logs}${directory}
        Log    ${directory} exists and is not empty
    END
    FOR    ${file}    IN    @{files_for_default_profile}
        File Should Exist    ${ELC_logs}${file}
        File Should Not Be Empty    ${ELC_logs}${file}
        Log    ${file} exists and is not empty
    END

Collector Log File for "Default" Profile Should Contain Required Text
    [Documentation] [Checks that Default Profile Created Files Have Correct Text]
    [Tags]    functional-default
    Validate document contains text
    ...    \\collector_log.txt
    ...    Targets: [X] Proc, [X] Drives, [X] Devices, [X] SvcsReg, [X] WinUpdates, [ ] PsHistory, [X] EvLogApp, [X] EvLogSys, [ ] EvLogSec, [X] SetupAPI, [X] EvLogLSM, [X] EvLogWMI, [ ] SysIn, [X] DrvLog, [X] NetCnf, [X] WinsockCat, [ ] WFPFil, [ ] AllReg, [X] TmpList, [ ] SchedTasks, [ ] WmiRepo, [ ] ShimDb, [ ] Prefetch
    Validate document contains text    \\collector_log.txt    === Proc ===
    Validate document contains text    \\collector_log.txt    === Drives ===
    Validate document contains text    \\collector_log.txt    === Devices ===
    Validate document contains text    \\collector_log.txt    === SvcsReg ===
    Validate document contains text    \\collector_log.txt    === WinUpdates ===
    Validate document contains text    \\collector_log.txt    === EvLogApp ===
    Validate document contains text    \\collector_log.txt    === EvLogSys ===
    Validate document contains text    \\collector_log.txt    === SetupAPI ===
    Validate document contains text    \\collector_log.txt    === EvLogLSM ===
    Validate document contains text    \\collector_log.txt    === DrvLog ===
    Validate document contains text    \\collector_log.txt    === NetCnf ===
    Validate document contains text    \\collector_log.txt    === WinsockCat ===
    Validate document contains text    \\collector_log.txt    === TmpList ===

Collection Profile Dropdown List Item Selection Should Work
    [Documentation] [Checks that Collection Profile Can Be Changed]
    [Tags]    dropdown functional
    Start ESET Log Collector App
    Check Element is Visible and Contains Text    ${collection_profile_dropdown}    Default
    FOR    ${list_item}    IN    @{list_items_collection_profile}
        Select Item From ComboBox And Validate Selected
        ...    ${collection_profile_dropdown}
        ...    ${list_item}
        ...    xpath=//ListItem[@Name="${list_item}"]
    END

ESET Logs Collection Mode DropDown List Item Selection Should Work
    [Documentation] [Checks that ESET Log Collection Mode Can Be Changed]
    [Tags]    dropdown functional
    Check Element is Visible and Contains Text    ${eset_logs_dropdown}    Original binary from disk
    FOR    ${list_item}    IN    @{list_items_eset_logs}
        Select Item From ComboBox And Validate Selected
        ...    ${eset_logs_dropdown}
        ...    ${list_item}
        ...    xpath=//ListItem[@Name="${list_item}"]
    END

Logs Age Limit DropDown List Item Selection Should Work
    [Documentation] [Checks that Logs Age Limit Can Be Changed]
    [Tags]    dropdown functional
    Start ESET Log Collector App
    Check Element is Visible    ${logs_age_dropdown}
    FOR    ${list_item}    IN    @{list_items_logs_age}
        Select Item From DropDown and Validate Selected
        ...    ${logs_age_dropdown}
        ...    ${logs_age_selected_value}
        ...    xpath=//ListItem[@Name="${list_item}"]
        ...    ${list_item}
    END
