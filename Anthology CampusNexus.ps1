#
# Anthology_SIS.ps1 - Anthology SIS (CampusNexus) API
#    Migrated to Powershell connector due to special handling needed for Writeback calls.
#        Specifically, can use OData to pull data, but Command API Endpoints to write data.
#        Need to first pull a record, generate the payload with any changes, and save that record back.
#

$Log_MaskableKeys = @(
    # Put a comma-separated list of attribute names here, whose value should be masked before 
    'Password',
    "apikey"
)

# System functions
#
function Idm-SystemInfo {
    param (
        # Operations
        [switch] $Connection,
        [switch] $TestConnection,
        [switch] $Configuration,
        # Parameters
        [string] $ConnectionParams
    )

    Log info "-Connection=$Connection -TestConnection=$TestConnection -Configuration=$Configuration -ConnectionParams='$ConnectionParams'"

    if ($Connection) {
        @(
            @{
                name = 'tenantid'
                type = 'textbox'
                label = 'Hostname'
                description = 'Hostname for Web Services'
                value = ''
            }
            @{
                name = 'apikey'
                type = 'textbox'
                label = 'API Key'
                label_indent = $true
                description = 'API Key'
                value = ''
            }
            @{
                name = 'pagesize'
                type = 'textbox'
                label = 'Page Size'
                label_indent = $true
                description = 'Number of records per page'
                value = '200'
            }
            @{
                name = 'use_proxy'
                type = 'checkbox'
                label = 'Use Proxy'
                description = 'Use Proxy server for requets'
                value = $false                  # Default value of checkbox item
            }
            @{
                name = 'proxy_address'
                type = 'textbox'
                label = 'Proxy Address'
                description = 'Address of the proxy server'
                value = 'http://localhost:8888'
                disabled = '!use_proxy'
                hidden = '!use_proxy'
            }
            @{
                name = 'use_proxy_credentials'
                type = 'checkbox'
                label = 'Use Proxy'
                description = 'Use Proxy server for requets'
                value = $false
                disabled = '!use_proxy'
                hidden = '!use_proxy'
            }
            @{
                name = 'proxy_username'
                type = 'textbox'
                label = 'Proxy Username'
                label_indent = $true
                description = 'Username account'
                value = ''
                disabled = '!use_proxy_credentials'
                hidden = '!use_proxy_credentials'
            }
            @{
                name = 'proxy_password'
                type = 'textbox'
                password = $true
                label = 'Proxy Password'
                label_indent = $true
                description = 'User account password'
                value = ''
                disabled = '!use_proxy_credentials'
                hidden = '!use_proxy_credentials'
            }
            @{
                name = 'nr_of_sessions'
                type = 'textbox'
                label = 'Max. number of simultaneous sessions'
                description = ''
                value = 1
            }
            @{
                name = 'sessions_idle_timeout'
                type = 'textbox'
                label = 'Session cleanup idle time (minutes)'
                description = ''
                value = 1
            }
        )
    }

    if ($TestConnection) {
        # Test is a failure only if an exception is thrown.
        $response = Idm-UsaStatesRead -SystemParams $ConnectionParams
    }

    if ($Configuration) {
        @()
    }

    Log info "Done"
}

function Idm-OnUnload {
}

#
# Object CRUD functions
#

$Global:Properties = @{
    Agencies = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AgencyTypeId"; options = @('default') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "FundSourceId"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "MainAgencyBranchId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    AgencyBranches = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AgencyId"; options = @('default') }
        @{ name = "BillingMethodId"; options = @('default') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "City"; options = @('default') }
        @{ name = "CompanyName"; options = @('default') }
        @{ name = "ContactFirstName"; options = @('default') }
        @{ name = "ContactLastName"; options = @('default') }
        @{ name = "CountryId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "Division"; options = @('default') }
        @{ name = "EmailAddress"; options = @('default') }
        @{ name = "GstNumber"; options = @('default') }
        @{ name = "IndustryId"; options = @('default') }
        @{ name = "InvoiceNumberMask"; options = @('default') }
        @{ name = "InvoiceType"; options = @('default') }
        @{ name = "IsDisbursementBatchCreated"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsSponsor"; options = @('default') }
        @{ name = "LastInvoiceNumber"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "LastStatementCloseDate"; options = @('default') }
        @{ name = "LastStatementDate"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "OrganizationId"; options = @('default') }
        @{ name = "PhoneNumber"; options = @('default') }
        @{ name = "PostalCode"; options = @('default') }
        @{ name = "State"; options = @('default') }
        @{ name = "StatementAmount"; options = @('default') }
        @{ name = "StatementComment"; options = @('default') }
        @{ name = "StreetAddress"; options = @('default') }
    )
    AgencyTypes = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    Buildings = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusId"; options = @('default') }
        @{ name = "City"; options = @('default') }
        @{ name = "CloseTime"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "Comment"; options = @('default') }
        @{ name = "ContactEmail"; options = @('default') }
        @{ name = "ContactName"; options = @('default') }
        @{ name = "ContactTitle"; options = @('default') }
        @{ name = "CountryId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "FaxNumber"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "LocationId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "NumberOfRooms"; options = @('default') }
        @{ name = "OpenTime"; options = @('default') }
        @{ name = "PhoneNumber"; options = @('default') }
        @{ name = "PostalCode"; options = @('default') }
        @{ name = "State"; options = @('default') }
        @{ name = "StreetAddress"; options = @('default') }
        @{ name = "Weekdays"; options = @('default') }
    )
    CampusGroups = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "ApproverStaffId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "FinancialCampusGroup"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "SaStmtComments"; options = @('default') }
        @{ name = "SaStmtLastCloseDate"; options = @('default') }
        @{ name = "Type"; options = @('default') }
    )
    Countries = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "PhoneMask"; options = @('default') }
        @{ name = "SsnMask"; options = @('default') }
    )
    Counties = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CountyFips"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "State"; options = @('default') }
    )
    EmployerGroups = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "DataQueryIdentifier"; options = @('default') }
        @{ name = "ExpirationDate"; options = @('default') }
        @{ name = "GroupType"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsPublicGroup"; options = @('default') }
        @{ name = "JobFrequency"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "LastRefreshDate"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "OwnerStaffId"; options = @('default') }
        @{ name = "SqlQuery"; options = @('default') }
        @{ name = "ViewQuery"; options = @('default') }
    )
    EmployerGroupMembers = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AddedByUserId"; options = @('default') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "EffectiveDate"; options = @('default') }
        @{ name = "EmployerGroupId"; options = @('default') }
        @{ name = "EmployerId"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "RemovedByUserId"; options = @('default') }
        @{ name = "RemovedDate"; options = @('default') }
    )
    Ethnicities = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    Genders = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    GenderPronouns = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    Industries = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "SicCode"; options = @('default') }
    )
    Locations = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "City"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CountryId"; options = @('default') }
        @{ name = "CountyId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "FaxNumber"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "PhoneNumber"; options = @('default') }
        @{ name = "PostalCode"; options = @('default') }
        @{ name = "StateCode"; options = @('default') }
        @{ name = "StreetAddress"; options = @('default') }
    )
    Nationalities = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    ProgramGroups = @(
        @{ name = "ProgramGroupId"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    ResidencyTypes = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    ResidencyTypeStatusCodeAssociations = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "ResidencyStatusCodeId"; options = @('default') }
        @{ name = "ResidencyTypeId"; options = @('default') }
    )
    ResidencyStatusCodes = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    Rooms = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "BuildingId"; options = @('default') }
        @{ name = "BuildingNumber"; options = @('default') }
        @{ name = "Capacity"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsConflictsChecked"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "RoomNumber"; options = @('default') }
    )
    SchoolDefinedFields = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "DataType"; options = @('default') }
        @{ name = "DisplayOrder"; options = @('default') }
        @{ name = "FieldDescription"; options = @('default') }
        @{ name = "HelpText"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsUsedForAutoAward"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Length"; options = @('default') }
        @{ name = "Precision"; options = @('default') }
        @{ name = "ValidationText"; options = @('default') }
        @{ name = "ValidationType"; options = @('default') }
        @{ name = "Visibility"; options = @('default') }
        @{ name = "VisibilityOnline"; options = @('default') }
    )
    SchoolStatusDetails = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AccountStatusId"; options = @('default') }
        @{ name = "CanChangeToSchoolStatusId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "DaysAllowed"; options = @('default') }
        @{ name = "DaysAllowedUndoStatusChange"; options = @('default') }
        @{ name = "DaysBeforeAllowed"; options = @('default') }
        @{ name = "IsAccountStatusChangeAllowed"; options = @('default') }
        @{ name = "IsAccountStatusOverridden"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsPlacedStatusOverriden"; options = @('default') }
        @{ name = "IsPlacementStatusChangeAllowed"; options = @('default') }
        @{ name = "IsRefundCalculationTriggered"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "PlacementStatusId"; options = @('default') }
        @{ name = "SchoolStatusId"; options = @('default') }
        @{ name = "StaffGroupId"; options = @('default') }
        @{ name = "SystemSchoolStatusDetailId"; options = @('default') }
    )
    SchoolStatuses = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "IsTitleIvWithdrawal"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "NsldsStatus"; options = @('default') }
        @{ name = "StatusDescription"; options = @('default') }
        @{ name = "SystemSchoolStatusId"; options = @('default') }
    )
    Staff = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AdmissionsRepTypeId"; options = @('default') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "CellPhoneNumber"; options = @('default') }
        @{ name = "CertificationList"; options = @('default') }
        @{ name = "City"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "ContactManagereStudentListInclude"; options = @('default') }
        @{ name = "ContactManagerStudentListShow"; options = @('default') }
        @{ name = "CountryId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "DefaultAwardYearId"; options = @('default') }
        @{ name = "DefaultModule"; options = @('default') }
        @{ name = "DefaultSyCampusId"; options = @('default') }
        @{ name = "DefaultTermId"; options = @('default') }
        @{ name = "Degree"; options = @('default') }
        @{ name = "Department"; options = @('default') }
        @{ name = "DocumentPolicyId"; options = @('default') }
        @{ name = "EmailAddress"; options = @('default') }
        @{ name = "EmailReplyTo"; options = @('default') }
        @{ name = "EmployeeNumber"; options = @('default') }
        @{ name = "EmploymentLegalEntityIdentifier"; options = @('default') }
        @{ name = "Extension"; options = @('default') }
        @{ name = "FirstName"; options = @('default') }
        @{ name = "FullName"; options = @('default') }
        @{ name = "HiredDate"; options = @('default') }
        @{ name = "HomePhoneNumber"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsAllowedAccessConnectedStudentEnrollmentPeriod"; options = @('default') }
        @{ name = "IsAllowedAccessMasterCourseProgramOverride"; options = @('default') }
        @{ name = "IsAllowedCommonlineHoldRelease"; options = @('default') }
        @{ name = "IsAllowedContactManagerShowAllOption"; options = @('default') }
        @{ name = "IsAllowedDateExclusion"; options = @('default') }
        @{ name = "IsAllowedEditTaskTemplateSource"; options = @('default') }
        @{ name = "IsAllowedEditTaxRatesPendingCharges"; options = @('default') }
        @{ name = "IsAllowedFulfillmentDpa"; options = @('default') }
        @{ name = "IsAllowedMultipleCampusGroups"; options = @('default') }
        @{ name = "IsAllowedOverrideAuditDesignationDeadline"; options = @('default') }
        @{ name = "IsAllowedOverrideClosedTerm"; options = @('default') }
        @{ name = "IsAllowedOverrideEnrollmentDates"; options = @('default') }
        @{ name = "IsAllowedOverrideMaxClass"; options = @('default') }
        @{ name = "IsAllowedReassignCourse"; options = @('default') }
        @{ name = "IsAllowedToAccessTransferCampus"; options = @('default') }
        @{ name = "IsAllowedToAccessTransferEnrollment"; options = @('default') }
        @{ name = "IsAllowedToAccessTransferEnrollmentAndCampus"; options = @('default') }
        @{ name = "IsAllowedToAddCollege"; options = @('default') }
        @{ name = "IsAllowedToAddCourse"; options = @('default') }
        @{ name = "IsAllowedToAssignAdmissionsRepEnrollment"; options = @('default') }
        @{ name = "IsAllowedToAssignPreviousEducationEnrollment"; options = @('default') }
        @{ name = "IsAllowedToCancelClassSection"; options = @('default') }
        @{ name = "IsAllowedToClearWaitlist"; options = @('default') }
        @{ name = "IsAllowedToEditAdvisor"; options = @('default') }
        @{ name = "IsAllowedToEditDisbursementDates"; options = @('default') }
        @{ name = "IsAllowedToEditExceptionDetails"; options = @('default') }
        @{ name = "IsAllowedToEditPaymentPeriods"; options = @('default') }
        @{ name = "IsAllowedToEditSystemDefinedBillingTransactionCode"; options = @('default') }
        @{ name = "IsAllowedToModifyFeeSchedule"; options = @('default') }
        @{ name = "IsAllowedToOverrideCodChangeStatus"; options = @('default') }
        @{ name = "IsAllowedToOverrideCourseContactHourComparison"; options = @('default') }
        @{ name = "IsAllowedToOverrideCoursePreRequisites"; options = @('default') }
        @{ name = "IsAllowedToOverrideCutoffDate"; options = @('default') }
        @{ name = "IsAllowedToOverrideDisbursementBatch"; options = @('default') }
        @{ name = "IsAllowedToOverrideFaHoldGroup"; options = @('default') }
        @{ name = "IsAllowedToOverrideIncompleteGradeExpirationDate"; options = @('default') }
        @{ name = "IsAllowedToOverrideInstructorCourseAssociation"; options = @('default') }
        @{ name = "IsAllowedToOverrideLastDateToWithdraw"; options = @('default') }
        @{ name = "IsAllowedToOverrideLockedTermSequence"; options = @('default') }
        @{ name = "IsAllowedToOverrideMaxClassUserCampuses"; options = @('default') }
        @{ name = "IsAllowedToOverrideMaxWaitList"; options = @('default') }
        @{ name = "IsAllowedToOverridePreCoRequisiteRequirement"; options = @('default') }
        @{ name = "IsAllowedToOverrideRegistrationGroup"; options = @('default') }
        @{ name = "IsAllowedToOverrideRegistrationHold"; options = @('default') }
        @{ name = "IsAllowedToOverrideRegistrationLocks"; options = @('default') }
        @{ name = "IsAllowedToOverrideSapDefinedDates"; options = @('default') }
        @{ name = "IsAllowedToOverrideSapPartialTerm"; options = @('default') }
        @{ name = "IsAllowedToOverrideSapPpDefinedDates"; options = @('default') }
        @{ name = "IsAllowedToOverrideSapStatus"; options = @('default') }
        @{ name = "IsAllowedToOverrideStatusChangeDays"; options = @('default') }
        @{ name = "IsAllowedToOverrideTranscriptHoldGroup"; options = @('default') }
        @{ name = "IsAllowedToOverrideTransferCreditApproval"; options = @('default') }
        @{ name = "IsAllowedToOverrideTransferOptions"; options = @('default') }
        @{ name = "IsAllowedToPerformManualRefundCalculation"; options = @('default') }
        @{ name = "IsAllowedToPrintChecksEditComment"; options = @('default') }
        @{ name = "IsAllowedToReallocateCenter"; options = @('default') }
        @{ name = "IsAllowedToRebuildTermSummaryRelationships"; options = @('default') }
        @{ name = "IsAllowedToViewSsnReports"; options = @('default') }
        @{ name = "IsAllowedToWaiveDegreeProgressRequirement"; options = @('default') }
        @{ name = "IsAllowedToWaiveRetakeFee"; options = @('default') }
        @{ name = "IsAssociateEmployerOtherCampusAllowed"; options = @('default') }
        @{ name = "IsAutoCmActivitiesAllowed"; options = @('default') }
        @{ name = "IsAutomatedUser"; options = @('default') }
        @{ name = "IsAxFaculty"; options = @('default') }
        @{ name = "IsBlockedViewSsnUi"; options = @('default') }
        @{ name = "IsCashier"; options = @('default') }
        @{ name = "IsConflictsChecked"; options = @('default') }
        @{ name = "IsContactManagerShownOnStartup"; options = @('default') }
        @{ name = "IsCustomSearchAllowed"; options = @('default') }
        @{ name = "IsDefaultReportWizardUsed"; options = @('default') }
        @{ name = "IsDeleteBilledChargesLeaseAllowed"; options = @('default') }
        @{ name = "IsDeleteUnbilledChargesLeaseAllowed"; options = @('default') }
        @{ name = "IsDropStatusMessageBox"; options = @('default') }
        @{ name = "IsDuplicateEmpOverrideAllowed"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsFacultySynced"; options = @('default') }
        @{ name = "IsGlobalSearchAllowed"; options = @('default') }
        @{ name = "IsHousingPeriodDateEditAllowed"; options = @('default') }
        @{ name = "IsJobTypeEditingSecurityAllowed"; options = @('default') }
        @{ name = "IsLocked"; options = @('default') }
        @{ name = "IsManualBillingNotAllowed"; options = @('default') }
        @{ name = "IsOverrideExecutiveReportOptionsAllowed"; options = @('default') }
        @{ name = "IsOverrideLeaseDateAllowed"; options = @('default') }
        @{ name = "IsOverrideRoomMaxCapacityAllowed"; options = @('default') }
        @{ name = "IsPrimaryContactSecurityAllowed"; options = @('default') }
        @{ name = "IsReportServerSelected"; options = @('default') }
        @{ name = "IsStudentListSaved"; options = @('default') }
        @{ name = "IsSystem"; options = @('default') }
        @{ name = "IsTest"; options = @('default') }
        @{ name = "IsToolbarUsed"; options = @('default') }
        @{ name = "IsUserLevelOverrideAccessAllowed"; options = @('default') }
        @{ name = "IsViewListBar"; options = @('default') }
        @{ name = "IsViewToolBar"; options = @('default') }
        @{ name = "Key"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "LastName"; options = @('default') }
        @{ name = "Mi"; options = @('default') }
        @{ name = "ModuleId"; options = @('default') }
        @{ name = "Note"; options = @('default') }
        @{ name = "Number"; options = @('default') }
        @{ name = "OfficePhoneNumber"; options = @('default') }
        @{ name = "Password"; options = @('default') }
        @{ name = "PasswordExpirationDate"; options = @('default') }
        @{ name = "PasswordRuleProfileId"; options = @('default') }
        @{ name = "PayRate"; options = @('default') }
        @{ name = "PayType"; options = @('default') }
        @{ name = "PersonId"; options = @('default') }
        @{ name = "PhoneNumber"; options = @('default') }
        @{ name = "Position"; options = @('default') }
        @{ name = "PostalCode"; options = @('default') }
        @{ name = "PreferredName"; options = @('default') }
        @{ name = "ReportDefault"; options = @('default') }
        @{ name = "ReportsToStaffId"; options = @('default') }
        @{ name = "Resume"; options = @('default') }
        @{ name = "Salt"; options = @('default') }
        @{ name = "SearchResults"; options = @('default') }
        @{ name = "ShowDefaultOnStartup"; options = @('default') }
        @{ name = "Signature"; options = @('default') }
        @{ name = "Ssn"; options = @('default') }
        @{ name = "StaffName"; options = @('default') }
        @{ name = "StaffPicture"; options = @('default') }
        @{ name = "State"; options = @('default') }
        @{ name = "StreetAddress"; options = @('default') }
        @{ name = "StreetAddress2"; options = @('default') }
        @{ name = "Suffix"; options = @('default') }
        @{ name = "TaskPolicyId"; options = @('default') }
        @{ name = "Title"; options = @('default') }
        @{ name = "WorkCity"; options = @('default') }
        @{ name = "WorkFaxPhoneNumber"; options = @('default') }
        @{ name = "WorkPostalCode"; options = @('default') }
        @{ name = "WorkState"; options = @('default') }
        @{ name = "WorkStreetAddress"; options = @('default') }
        @{ name = "WorkStreetAddress2"; options = @('default') }
    )
    StaffGroups = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AdvisorModule"; options = @('default') }
        @{ name = "AllowDropLdaAttendChange"; options = @('default') }
        @{ name = "CanOverrideLeadDuplicateWarning"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "GroupType"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsCampusLinkAmbassadorUse"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsPositivePayUse"; options = @('default') }
        @{ name = "IsRequiredForEnroll"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    StaffGroupFundSourcePermissions = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "FundSourceId"; options = @('default') }
        @{ name = "IsAllowedToAdd"; options = @('default') }
        @{ name = "IsAllowedToApprove"; options = @('default') }
        @{ name = "IsAllowedToDelete"; options = @('default') }
        @{ name = "IsAllowedToDeletePaidRefund"; options = @('default') }
        @{ name = "IsAllowedToDeletePaidStipend"; options = @('default') }
        @{ name = "IsAllowedToDeletePayment"; options = @('default') }
        @{ name = "IsAllowedToDeleteScheduledRefund"; options = @('default') }
        @{ name = "IsAllowedToDeleteScheduledStipend"; options = @('default') }
        @{ name = "IsAllowedToEdit"; options = @('default') }
        @{ name = "IsAllowedToEditPaidRefund"; options = @('default') }
        @{ name = "IsAllowedToEditPaidStipend"; options = @('default') }
        @{ name = "IsAllowedToEditPayeeOnScheduledRefund"; options = @('default') }
        @{ name = "IsAllowedToEditPayeeOnScheduledStipend"; options = @('default') }
        @{ name = "IsAllowedToEditPayment"; options = @('default') }
        @{ name = "IsAllowedToEditScheduledRefund"; options = @('default') }
        @{ name = "IsAllowedToEditScheduledStipend"; options = @('default') }
        @{ name = "IsAllowedToPost"; options = @('default') }
        @{ name = "IsAllowedToPostRefund"; options = @('default') }
        @{ name = "IsAllowedToPostStipend"; options = @('default') }
        @{ name = "IsAllowedToScheduleRefund"; options = @('default') }
        @{ name = "IsAllowedToScheduleStipend"; options = @('default') }
        @{ name = "IsAllowedToView"; options = @('default') }
        @{ name = "IsAllowedToVoidPaidRefund"; options = @('default') }
        @{ name = "IsAllowedToVoidPaidStipend"; options = @('default') }
        @{ name = "IsAllowedToVoidPayment"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "StaffGroupId"; options = @('default') }
    )
    StaffGroupRefreshRules = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "Frequency"; options = @('default') }
        @{ name = "IsRefreshAllowed"; options = @('default') }
        @{ name = "LastModfiedUserId"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "StaffGroupId"; options = @('default') }
    )
    Students = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AcgEligReasonCode"; options = @('default') }
        @{ name = "AgencyId"; options = @('default') }
        @{ name = "AlienNumber"; options = @('default') }
        @{ name = "ArAccountStatus"; options = @('default') }
        @{ name = "ArBalance"; options = @('default') }
        @{ name = "ArNextTransactionNumber"; options = @('default') }
        @{ name = "AssignedAdmissionsRepId"; options = @('default') }
        @{ name = "AthleticIdentifier"; options = @('default') }
        @{ name = "BestTimeToContact"; options = @('default') }
        @{ name = "CampusId"; options = @('default') }
        @{ name = "CitizenId"; options = @('default') }
        @{ name = "City"; options = @('default') }
        @{ name = "CollegeId"; options = @('default') }
        @{ name = "CountryId"; options = @('default') }
        @{ name = "CountyId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "CumulativeGpa"; options = @('default') }
        @{ name = "CumulativeGpaPoints"; options = @('default') }
        @{ name = "CurrencyCodeId"; options = @('default') }
        @{ name = "CurrentLda"; options = @('default') }
        @{ name = "DataBlockIndicator"; options = @('default') }
        @{ name = "DateOfBirth"; options = @('default') }
        @{ name = "DbiModifiedDate"; options = @('default') }
        @{ name = "DefaultAddressCode"; options = @('default') }
        @{ name = "DefaultMasterStudentAddressId"; options = @('default') }
        @{ name = "DefaultStudentAddressId"; options = @('default') }
        @{ name = "Disabled"; options = @('default') }
        @{ name = "DriverLicenseNumber"; options = @('default') }
        @{ name = "DriverLicenseState"; options = @('default') }
        @{ name = "EmailAddress"; options = @('default') }
        @{ name = "EmployabilityAboutInfo"; options = @('default') }
        @{ name = "EmployerId"; options = @('default') }
        @{ name = "EmploymentStatusId"; options = @('default') }
        @{ name = "ExternalStudentIdentifier"; options = @('default') }
        @{ name = "ExtraCurricularActivityId"; options = @('default') }
        @{ name = "FacebookUrl"; options = @('default') }
        @{ name = "FaGradPlusCounselingDate"; options = @('default') }
        @{ name = "FaRigorousHighSchoolProgramCodeId"; options = @('default') }
        @{ name = "FirstName"; options = @('default') }
        @{ name = "FullName"; options = @('default') }
        @{ name = "GenderId"; options = @('default') }
        @{ name = "GpaCredits"; options = @('default') }
        @{ name = "HispanicLatino"; options = @('default') }
        @{ name = "HsAcademicGpa"; options = @('default') }
        @{ name = "InstagramUrl"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsAllowedBulkRegistrationByTrack"; options = @('default') }
        @{ name = "IsBadAddress"; options = @('default') }
        @{ name = "IsBadPhone"; options = @('default') }
        @{ name = "IsDdVeteran"; options = @('default') }
        @{ name = "IsEftDefaultForStipends"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsInDistrict"; options = @('default') }
        @{ name = "IsSscrError11Received"; options = @('default') }
        @{ name = "LastActivityDate"; options = @('default') }
        @{ name = "LastFourSsn"; options = @('default') }
        @{ name = "LastInterestDate"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "LastName"; options = @('default') }
        @{ name = "LastNameFirstFour"; options = @('default') }
        @{ name = "LastStatementBeginDate"; options = @('default') }
        @{ name = "LastStatementCloseDate"; options = @('default') }
        @{ name = "LastStatementDate"; options = @('default') }
        @{ name = "LeadDate"; options = @('default') }
        @{ name = "LeadSourceId"; options = @('default') }
        @{ name = "LeadTypeId"; options = @('default') }
        @{ name = "LinkedInUrl"; options = @('default') }
        @{ name = "MaidenName"; options = @('default') }
        @{ name = "MaritalStatusId"; options = @('default') }
        @{ name = "Mi"; options = @('default') }
        @{ name = "MiddleName"; options = @('default') }
        @{ name = "MobilePhoneNumber"; options = @('default') }
        @{ name = "NationalityId"; options = @('default') }
        @{ name = "NickName"; options = @('default') }
        @{ name = "NiStudent"; options = @('default') }
        @{ name = "Note"; options = @('default') }
        @{ name = "OriginalAssignedAdmissionsRepId"; options = @('default') }
        @{ name = "OriginalExpectedStartDate"; options = @('default') }
        @{ name = "OriginalStartDate"; options = @('default') }
        @{ name = "OtherEmailAddress"; options = @('default') }
        @{ name = "OtherPhoneNumber"; options = @('default') }
        @{ name = "PersonId"; options = @('default') }
        @{ name = "PhoneNumber"; options = @('default') }
        @{ name = "Pin"; options = @('default') }
        @{ name = "PostalCode"; options = @('default') }
        @{ name = "PostalCodeFirstThree"; options = @('default') }
        @{ name = "PreferredContactType"; options = @('default') }
        @{ name = "PreferredName"; options = @('default') }
        @{ name = "PreviousEducationGpa"; options = @('default') }
        @{ name = "PreviousEducationId"; options = @('default') }
        @{ name = "ProgramGroupId"; options = @('default') }
        @{ name = "ProgramId"; options = @('default') }
        @{ name = "RawFirstName"; options = @('default') }
        @{ name = "RawLastName"; options = @('default') }
        @{ name = "RawPhoneNumber"; options = @('default') }
        @{ name = "SchoolStatusId"; options = @('default') }
        @{ name = "ShiftId"; options = @('default') }
        @{ name = "SmsServiceProviderId"; options = @('default') }
        @{ name = "SourceSystem"; options = @('default') }
        @{ name = "Ssn"; options = @('default') }
        @{ name = "StartDate"; options = @('default') }
        @{ name = "State"; options = @('default') }
        @{ name = "StatementComment"; options = @('default') }
        @{ name = "StreetAddress"; options = @('default') }
        @{ name = "StreetAddress2"; options = @('default') }
        @{ name = "StudentFullName"; options = @('default') }
        @{ name = "StudentIdentifier"; options = @('default') }
        @{ name = "StudentNumber"; options = @('default') }
        @{ name = "SubscribeToSms"; options = @('default') }
        @{ name = "Suffix"; options = @('default') }
        @{ name = "SuffixId"; options = @('default') }
        @{ name = "TitleId"; options = @('default') }
        @{ name = "TwitterUrl"; options = @('default') }
        @{ name = "Veteran"; options = @('default') }
        @{ name = "WorkPhoneNumber"; options = @('default') }
        @{ name = "WorkPhoneNumberExtension"; options = @('default') }
    )
    StudentAdvisors = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "StaffGroupId"; options = @('default') }
        @{ name = "StudentEnrollmentPeriodId"; options = @('default') }
        @{ name = "AdvisorModule"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "StaffId"; options = @('default') }
    )
    StudentActiveEnrollWithProgram = @(
        @{ name = "StudentId"; options = @('default','key') }
        @{ name = "FullName"; options = @('default') }
        @{ name = "StudentNumber"; options = @('default') }
        @{ name = "EnrollId"; options = @('default') }
        @{ name = "CampusId"; options = @('default') }
        @{ name = "CampusName"; options = @('default') }
        @{ name = "ProgramId"; options = @('default') }
        @{ name = "ProgramName"; options = @('default') }
    )
    StudentAgencyBranches = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AgencyBranchId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "EndDate"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsPrimaryBillingAffiliate"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Location"; options = @('default') }
        @{ name = "Note"; options = @('default') }
        @{ name = "StartDate"; options = @('default') }
        @{ name = "StudentFunction"; options = @('default') }
        @{ name = "StudentId"; options = @('default') }
        @{ name = "Title"; options = @('default') }
    )
    StudentGroups = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CampusGroupId"; options = @('default') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "DataQueryIdentifier"; options = @('default') }
        @{ name = "ExpirationDate"; options = @('default') }
        @{ name = "GroupType"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsPortalGroup"; options = @('default') }
        @{ name = "IsPublic"; options = @('default') }
        @{ name = "IsSprocQuery"; options = @('default') }
        @{ name = "IsTransferMonitoringGroup"; options = @('default') }
        @{ name = "IsUsedForAutoAwardCoa"; options = @('default') }
        @{ name = "IsUsedForAutoAwardRules"; options = @('default') }
        @{ name = "JobFrequency"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "LastRefreshDate"; options = @('default') }
        @{ name = "Name"; options = @('default') }
        @{ name = "OwnerStaffId"; options = @('default') }
        @{ name = "PreserveManualAddedStudentsOnRefresh"; options = @('default') }
        @{ name = "SqlQuery"; options = @('default') }
        @{ name = "ViewQuery"; options = @('default') }
    )
    StudentGroupMembers = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AddedByUserId"; options = @('default') }
        @{ name = "AwardYear"; options = @('default') }
        @{ name = "CampusId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "EffectiveDate"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsManualUpdated"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "RemovedByUserId"; options = @('default') }
        @{ name = "RemovedDate"; options = @('default') }
        @{ name = "StudentGroupId"; options = @('default') }
        @{ name = "StudentId"; options = @('default') }
    )
    StudentEnrollmentPeriods = @(
        @{ name = "Id"; options = @('default','key') },
        @{ name = "AcademicAdvisorId"; options = @('default') },
        @{ name = "AccountReceivableBalance"; options = @('default') },
        @{ name = "ActualStartDate"; options = @('default') },
        @{ name = "AdmissionsRegionId"; options = @('default') },
        @{ name = "AosTransferDate"; options = @('default') },
        @{ name = "ApplicantProgress"; options = @('default') },
        @{ name = "ApplicantTypeId"; options = @('default') },
        @{ name = "ApplicationReceivedDate"; options = @('default') },
        @{ name = "AssignedAdmissionsRepId"; options = @('default') },
        @{ name = "AutoChargesTermId"; options = @('default') },
        @{ name = "BilledDate"; options = @('default') },
        @{ name = "BillingMethodId"; options = @('default') },
        @{ name = "CampusId"; options = @('default') },
        @{ name = "CatalogYearId"; options = @('default') },
        @{ name = "ClockHoursAttempted"; options = @('default') },
        @{ name = "ClockHoursEarned"; options = @('default') },
        @{ name = "ClockHoursRequired"; options = @('default') },
        @{ name = "ClockHoursScheduled"; options = @('default') },
        @{ name = "CoreCreditHoursAttempted"; options = @('default') },
        @{ name = "CoreCreditHoursEarned"; options = @('default') },
        @{ name = "CoreGpa"; options = @('default') },
        @{ name = "CoreNumericAvg"; options = @('default') },
        @{ name = "CreatedDateTime"; options = @('default') },
        @{ name = "CreditHoursAttempted"; options = @('default') },
        @{ name = "CreditHoursEarned"; options = @('default') },
        @{ name = "CreditHoursRequired"; options = @('default') },
        @{ name = "CreditHoursScheduled"; options = @('default') },
        @{ name = "CumGpaPoints"; options = @('default') },
        @{ name = "DaysAbsent"; options = @('default') },
        @{ name = "DegreeAudit"; options = @('default') },
        @{ name = "DropDate"; options = @('default') },
        @{ name = "DropEarn"; options = @('default') },
        @{ name = "DropType"; options = @('default') },
        @{ name = "EnrollmentDate"; options = @('default') },
        @{ name = "EnrollmentNumber"; options = @('default') },
        @{ name = "EnrollmentStatusId"; options = @('default') },
        @{ name = "ExpectedCreditsHoursPerTerm"; options = @('default') },
        @{ name = "ExpectedHoursPerWeekForExternship"; options = @('default') },
        @{ name = "ExpectedRefundProcessDate"; options = @('default') },
        @{ name = "ExpectedStartDate"; options = @('default') },
        @{ name = "ExternshipBeginDate"; options = @('default') },
        @{ name = "FaEnrollmentStatusId"; options = @('default') },
        @{ name = "FaEntranceInterviewDate"; options = @('default') },
        @{ name = "FaExitInterviewDate"; options = @('default') },
        @{ name = "FinancialAidCredits"; options = @('default') },
        @{ name = "Gpa"; options = @('default') },
        @{ name = "GpaCreditHours"; options = @('default') },
        @{ name = "GradeLevelId"; options = @('default') },
        @{ name = "GradeScaleId"; options = @('default') },
        @{ name = "GraduationDate"; options = @('default') },
        @{ name = "IpedsState"; options = @('default') },
        @{ name = "IsApplicant"; options = @('default') },
        @{ name = "IsAttendanceArchived"; options = @('default') },
        @{ name = "IsExcludedCrmIntegration"; options = @('default') },
        @{ name = "IsIpedsTransfer"; options = @('default') },
        @{ name = "IsReenrollment"; options = @('default') },
        @{ name = "IsTransfer"; options = @('default') },
        @{ name = "IsUiUpdate"; options = @('default') },
        @{ name = "LastActivityDate"; options = @('default') },
        @{ name = "LastModifiedDateTime"; options = @('default') },
        @{ name = "LastModifiedUserId"; options = @('default') },
        @{ name = "Lda"; options = @('default') },
        @{ name = "LinkedSapStudentEnrollmentPeriodId"; options = @('default') },
        @{ name = "MidpointDate"; options = @('default') },
        @{ name = "MinutesAbsent"; options = @('default') },
        @{ name = "MinutesAttended"; options = @('default') },
        @{ name = "MinutesMakeUp"; options = @('default') },
        @{ name = "Note"; options = @('default') },
        @{ name = "NsldsWithdrawalDate"; options = @('default') },
        @{ name = "NumberOfCategoriesMultipleFulfillmentApplied"; options = @('default') },
        @{ name = "NumericAverage"; options = @('default') },
        @{ name = "OriginalAssignedAdmissionsRepId"; options = @('default') },
        @{ name = "OriginalExpectedStartDate"; options = @('default') },
        @{ name = "OriginalGraduationDate"; options = @('default') },
        @{ name = "OutsideCourseWorkHours"; options = @('default') },
        @{ name = "PreviousEducationId"; options = @('default') },
        @{ name = "PreviousGradDate"; options = @('default') },
        @{ name = "ProgramId"; options = @('default') },
        @{ name = "ProgramVersionId"; options = @('default') },
        @{ name = "ProgramVersionName"; options = @('default') },
        @{ name = "RecalculateTermSequence"; options = @('default') },
        @{ name = "ReenrollDate"; options = @('default') },
        @{ name = "ReentryAfter180Date"; options = @('default') },
        @{ name = "RegistrationCohortId"; options = @('default') },
        @{ name = "RightsResponsibilitiesAck"; options = @('default') },
        @{ name = "SapCheckpoint"; options = @('default') },
        @{ name = "SapFlag"; options = @('default') },
        @{ name = "SapStatusId"; options = @('default') },
        @{ name = "SchoolStatusChangeDate"; options = @('default') },
        @{ name = "SchoolStatusChangeReasonId"; options = @('default') },
        @{ name = "SchoolStatusId"; options = @('default') },
        @{ name = "ShiftId"; options = @('default') },
        @{ name = "SpeProgression"; options = @('default') },
        @{ name = "StartDateId"; options = @('default') },
        @{ name = "StartTermId"; options = @('default') },
        @{ name = "StatusChangeType"; options = @('default') },
        @{ name = "StudentId"; options = @('default') },
        @{ name = "TranscriptIssued"; options = @('default') },
        @{ name = "TransferCreditHours"; options = @('default') },
        @{ name = "TransferInDate"; options = @('default') }
    )
    StudentRelationshipAddresses = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "IsPermanentAddress"; options = @('default') }
        @{ name = "AddressBeginDate"; options = @('default') }
        @{ name = "AddressEndDate"; options = @('default') }
        @{ name = "AddressTypeId"; options = @('default') }
        @{ name = "AdmissionsRegionId"; options = @('default') }
        @{ name = "City"; options = @('default') }
        @{ name = "CountryId"; options = @('default') }
        @{ name = "CountryName"; options = @('default') }
        @{ name = "CountyId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "EmailAddress"; options = @('default') }
        @{ name = "EmployerName"; options = @('default') }
        @{ name = "FirstName"; options = @('default') }
        @{ name = "FullName"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsSeasonalAddress"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "LastName"; options = @('default') }
        @{ name = "MobileNumber"; options = @('default') }
        @{ name = "Note"; options = @('default') }
        @{ name = "OtherEmailAddress"; options = @('default') }
        @{ name = "OtherPhone"; options = @('default') }
        @{ name = "PhoneNumber"; options = @('default') }
        @{ name = "PlusReferenceNumber"; options = @('default') }
        @{ name = "PostalCode"; options = @('default') }
        @{ name = "PrintedOnMasterPromNote"; options = @('default') }
        @{ name = "PrintedOnPlusPromNote"; options = @('default') }
        @{ name = "ReferenceConfirmed"; options = @('default') }
        @{ name = "ReferenceConfirmedDate"; options = @('default') }
        @{ name = "ReferenceNumber"; options = @('default') }
        @{ name = "RelationToStudent"; options = @('default') }
        @{ name = "SecondPhoneNumber"; options = @('default') }
        @{ name = "SourceSystem"; options = @('default') }
        @{ name = "Ssn"; options = @('default') }
        @{ name = "State"; options = @('default') }
        @{ name = "StreetAddress"; options = @('default') }
        @{ name = "StreetAddress2"; options = @('default') }
        @{ name = "StudentEnrollmentPeriodId"; options = @('default') }
        @{ name = "StudentId"; options = @('default') }
        @{ name = "TitleId"; options = @('default') }
        @{ name = "WorkPhoneNumber"; options = @('default') }
        @{ name = "YearsAtAddress"; options = @('default') }
        @{ name = "YearsKnownStudent"; options = @('default') }
    )
    StudentResidencyDetails = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "EffectiveDate"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Note"; options = @('default') }
        @{ name = "ResidencyStatusCodeId"; options = @('default') }
        @{ name = "ResidencyTypeId"; options = @('default') }
        @{ name = "StudentId"; options = @('default') }
    )
    StudentSchoolDefinedFieldValues = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "FieldValue"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "SchoolDefinedFieldId"; options = @('default') }
        @{ name = "StudentId"; options = @('default') }
    )
    StudentSchoolStatusHistory = @(
        @{ name = "id"; options = @('default','key') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "EffectiveDate"; options = @('default') }
        @{ name = "EnrollmentStatusNewUnitValue"; options = @('default') }
        @{ name = "EnrollmentStatusPreviousUnitValue"; options = @('default') }
        @{ name = "EnrollmentStatusTermId"; options = @('default') }
        @{ name = "InternalNote"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Lda"; options = @('default') }
        @{ name = "NewEnrollmentStatusId"; options = @('default') }
        @{ name = "NewSchoolStatusId"; options = @('default') }
        @{ name = "NewSystemSchoolStatusId"; options = @('default') }
        @{ name = "Note"; options = @('default') }
        @{ name = "NsldsWithdrawalDate"; options = @('default') }
        @{ name = "PreviousEnrollmentStatusId"; options = @('default') }
        @{ name = "PreviousSchoolStatusId"; options = @('default') }
        @{ name = "PreviousSystemSchoolStatusId"; options = @('default') }
        @{ name = "SchoolStatusChangeReasonId"; options = @('default') }
        @{ name = "StatusBeginDate"; options = @('default') }
        @{ name = "StatusChangeRecordStatus"; options = @('default') }
        @{ name = "StatusChangeType"; options = @('default') }
        @{ name = "StatusReturnDate"; options = @('default') }
        @{ name = "StudentEnrollmentPeriodId"; options = @('default') }
        @{ name = "StudentId"; options = @('default') }
        @{ name = "StudentSchoolStatusDescription"; options = @('default') }
        @{ name = "TaskId"; options = @('default') }
    )
    Suffixes = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    SystemSchoolStatusDetails = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "AccountStatusId"; options = @('default') }
        @{ name = "CanChangeToSystemSchoolStatusId"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsAccountStatusChangeAllowed"; options = @('default') }
        @{ name = "IsAccountStatusOverridden"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsPlacedStatusOverridden"; options = @('default') }
        @{ name = "IsPlacementStatusChangeAllowed"; options = @('default') }
        @{ name = "IsRefundCalcTriggered"; options = @('default') }
        @{ name = "IsSchoolStatusGridUsed"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "MaxAllowedDaysElapsedFromLastStatusChange"; options = @('default') }
        @{ name = "MaxDaysAllowUndoStatusChange"; options = @('default') }
        @{ name = "MinAllowedDaysElapsedFromLastStatusChange"; options = @('default') }
        @{ name = "PlacementStatusId"; options = @('default') }
        @{ name = "StaffGroupId"; options = @('default') }
        @{ name = "SystemSchoolStatusId"; options = @('default') }
    )
    Titles = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "IsSystemCode"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
    UsaStates = @(
        @{ name = "Id"; options = @('default','key') }
        @{ name = "Code"; options = @('default') }
        @{ name = "CreatedDateTime"; options = @('default') }
        @{ name = "IsActive"; options = @('default') }
        @{ name = "IsExcludedCrmIntegration"; options = @('default') }
        @{ name = "LastModifiedDateTime"; options = @('default') }
        @{ name = "LastModifiedUserId"; options = @('default') }
        @{ name = "Name"; options = @('default') }
    )
}

function Idm-AgencyBranchesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "AgencyBranches"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-AgenciesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Agencies"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-AgencyTypesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "AgencyTypes"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-BuildingsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Buildings"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-CampusGroupsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "CampusGroups"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-CountriesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Countries"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-CountiesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Counties"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-EmployerGroupsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "EmployerGroups"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-EmployerGroupMembersRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "EmployerGroupMembers"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-EthnicitiesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Ethnicities"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-GendersRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Genders"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-GenderPronounsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "GenderPronouns"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-IndustriesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Industries"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-LocationsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Locations"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-NationalitiesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Nationalities"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-ProgramGroupsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "ProgramGroups"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-ResidencyTypesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "ResidencyTypes"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-ResidencyTypeStatusCodeAssociationsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "ResidencyTypeStatusCodeAssociations"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-ResidencyStatusCodesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "ResidencyStatusCodes"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-RoomsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Rooms"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-SchoolDefinedFieldsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "SchoolDefinedFields"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-SchoolStatusDetailsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "SchoolStatusDetails"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-SchoolStatusesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "SchoolStatuses"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StaffRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Staff"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StaffGroupsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StaffGroups"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StaffGroupFundSourcePermissionsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StaffGroupFundSourcePermissions"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StaffGroupRefreshRulesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StaffGroupRefreshRules"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Students"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentAdvisorsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentAdvisors"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentActiveEnrollWithProgramRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentActiveEnrollWithProgram"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentAgencyBranchesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentAgencyBranches"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentGroupsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentGroups"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentGroupMembersRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentGroupMembers"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentEnrollmentPeriodsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentEnrollmentPeriods"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentRelationshipAddressesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentRelationshipAddresses"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentResidencyDetailsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentResidencyDetails"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentSchoolDefinedFieldValuesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentSchoolDefinedFieldValues"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-StudentSchoolStatusHistoryRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "StudentSchoolStatusHistory"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-SuffixesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Suffixes"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-SystemSchoolStatusDetailsRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "SystemSchoolStatusDetails"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-TitlesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "Titles"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

function Idm-UsaStatesRead {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams
    )
    $Class = "UsaStates"
    Get-OData -GetMeta:$GetMeta -SystemParams $SystemParams -FunctionParams $FunctionParams -Class $Class

    Log info "Done"
}

# Create & Update Logic
function Idm-StudentSchoolDefinedFieldValuesCreate {
    param (
        # Operations
        [switch] $GetMeta,
        # Parameters
        [string] $SystemParams,
        [string] $FunctionParams
    )

    Log info "-GetMeta=$GetMeta -SystemParams='$SystemParams' -FunctionParams='$FunctionParams'"
    $function_params = ConvertFrom-Json2 $FunctionParams
    $system_params   = ConvertFrom-Json2 $SystemParams

    if ($GetMeta) {
        #
        # Get meta data
        #
        @{
            semantics = 'create'
            parameters = @( 
                @{ name = 'fieldValue';allowance = 'mandatory'   },
                @{ name = 'schoolDefinedFieldId';     allowance = 'mandatory'  },
                @{ name = 'studentId';     allowance = 'mandatory'  },
                @{ name = '*';              allowance = 'prohibited' }
            )
        }
    }
    else {
        #
        # Execute function
        #
        $params = @{
            URI = 'https://{0}/api/commands/Common/StudentSchoolDefinedFieldValue/saveNew' -f $system_params.tenantId
            Method = 'POST'
            Headers = @{
                    authorization = 'ApplicationKey {0}' -f $system_params.apiKey
                    accept = '*/*'
                    'Content-Type' = 'application/json; charset=utf-8'
                }
            Body = @{
                    payload = @{
                      "isExcludedCrmIntegration"= $false
                      "id"= 0
                      "createdDateTime" = (get-date -format o)
                      "fieldValue"= "{0}" -f $function_params.'fieldValue'
                      "schoolDefinedFieldId"= $function_params.'schoolDefinedFieldId'
                      "studentId"= $function_params.'studentId'
                    }
            } | ConvertTo-Json -Depth 50
            TimeoutSec = 20
        }
        $post_response = Invoke-RestMethod @params

        # Prepare and return data
        $l_properties = ($Global:Properties.'StudentSchoolDefinedFieldValues' ).name
        $hash_table = [ordered]@{}
        foreach ($column_name in $l_properties) {
            $hash_table[$column_name] = $post_response.payload.data.$column_name
        }
            
        Log info ("Response: {0}" -f ($post_response | ConvertTo-Json -Depth 2 ))
        Log info ("HashTable: {0}" -f ($hash_table | ConvertTo-Json -Depth 2 ))
        # Output new record.
        $hash_table
    }
    Log info ("Done")
}

function Idm-StudentSchoolDefinedFieldValuesUpdate {
    param (
        # Operations
        [switch] $GetMeta,
        # Parameters
        [string] $SystemParams,
        [string] $FunctionParams
    )

    Log info "-GetMeta=$GetMeta -SystemParams='$SystemParams' -FunctionParams='$FunctionParams'"
    $function_params = ConvertFrom-Json2 $FunctionParams
    $system_params   = ConvertFrom-Json2 $SystemParams

    if ($GetMeta) {
        #
        # Get meta data
        #
        @{
            semantics = 'update'
            parameters = @( 
                @{ name = 'Id';allowance = 'mandatory'   },
                @{ name = 'FieldValue';allowance = 'optional'   },
                @{ name = 'SchoolDefinedFieldId';     allowance = 'optional'  },
                @{ name = 'StudentId';     allowance = 'optional'  },
                @{ name = '*';              allowance = 'prohibited' }
            )
        }
    }
    else {
        #
        # Execute function
        #
        
        # Pull current record:
        $params = @{
            URI = 'https://{0}/api/commands/Common/StudentSchoolDefinedFieldValue/get' -f $system_params.tenantId
            Method = 'POST'
            Headers = @{
                    authorization = 'ApplicationKey {0}' -f $system_params.apiKey
                    accept = '*/*'
                    'Content-Type' = 'application/json; charset=utf-8'
                }
            Body = @{
                payload =  @{
                    id =  $function_params.id
                }
            } | ConvertTo-Json -Depth 50
            TimeoutSec = 20
        }
        $post_get_response = Invoke-RestMethod @params
        
        # Compare and update fields as needed.
        if($post_get_response.payload.count -eq 0) 
        {
            $msg = "Invalid ID Specified: {0}" -f $function_params.id
            Log error $msg
            throw $msg
        }

        $newPayload = $post_get_response.payload.data
        foreach ($key in $function_params.Keys)
        {
            $newPayload.$key = $function_params.$key
        }

        # Write data back
        $params = @{
            URI = 'https://{0}/api/commands/Common/StudentSchoolDefinedFieldValue/save' -f $system_params.tenantId
            Method = 'POST'
            Headers = @{
                    authorization = 'ApplicationKey {0}' -f $system_params.apiKey
                    accept = '*/*'
                    'Content-Type' = 'application/json; charset=utf-8'
                }
            Body = @{
                    payload = $newPayload
            } | ConvertTo-Json -Depth 50
            TimeoutSec = 20
        }
        $post_response = Invoke-RestMethod @params
        
        #Log info ("Response: {0}" -f ($post_response | ConvertTo-Json -Depth 2 ))
        
        # Output new record.
        
        $post_response.payload.data
    }
    Log info ("Done")
}

# Update Student.
function Idm-StudentsUpdate {
    param (
        # Operations
        [switch] $GetMeta,
        # Parameters
        [string] $SystemParams,
        [string] $FunctionParams
    )

    Log info "-GetMeta=$GetMeta -SystemParams='$SystemParams' -FunctionParams='$FunctionParams'"
    $function_params = ConvertFrom-Json2 $FunctionParams
    $system_params   = ConvertFrom-Json2 $SystemParams

    if ($GetMeta) {
        #
        # Get meta data
        #
        @{
            semantics = 'update'
            parameters = @( 
                @{ name = 'Id';allowance = 'mandatory'   },
                @{ name = 'LastModifiedDateTime';allowance = 'prohibited'   },
                @{ name = 'LastModifiedUserId';allowance = 'prohibited'   },
                @{ name = 'CreatedDateTime';allowance = 'prohibited'   },
                @{ name = '*';              allowance = 'optional' }
            )
        }
    }
    else {
        #
        # Execute function
        #
        
        # Pull current record:
        $params = @{
            URI = 'https://{0}/api/commands/Common/Student/get' -f $system_params.tenantId
            Method = 'POST'
            Headers = @{
                    authorization = 'ApplicationKey {0}' -f $system_params.apiKey
                    accept = '*/*'
                    'Content-Type' = 'application/json; charset=utf-8'
                }
            Body = @{
                payload =  @{
                    id =  $function_params.id
                }
            } | ConvertTo-Json -Depth 50
            TimeoutSec = 20
        }
        $post_get_response = Invoke-RestMethod @params
        
        # Compare and update fields as needed.
        if($post_get_response.payload.count -eq 0)
        {
            $msg = "Invalid ID Specified: {0}" -f $function_params.id
            Log error $msg
            throw $msg
        }

        $newPayload = $post_get_response.payload.data
        foreach ($key in $function_params.Keys)
        {
            $newPayload.$key = $function_params.$key
        }
        
        # Hard set the studentAddressAssociation to 1.  Else will fail if it thinks an Address field is touched.
        #  TODO:  Figure out exactly what fields require this field set if they are changed.
        $newPayload.studentAddressAssociation = 1

        # Write data back
        $params = @{
            URI = 'https://{0}/api/commands/Common/Student/save' -f $system_params.tenantId
            Method = 'POST'
            Headers = @{
                    authorization = 'ApplicationKey {0}' -f $system_params.apiKey
                    accept = '*/*'
                    'Content-Type' = 'application/json; charset=utf-8'
                }
            Body = [System.Text.Encoding]::UTF8.GetBytes((@{
                    payload = $newPayload
            } | ConvertTo-Json -Depth 50))
            TimeoutSec = 20
        }
        $post_response = Invoke-RestMethod @params
        
        #Log info ("Response: {0}" -f ($post_response | ConvertTo-Json -Depth 2 ))
        
        # Output new record.
        $post_response.payload.data
    }
    Log info ("Done")
}

function Idm-StudentRelationshipAddressesCreate {
    param (
        # Operations
        [switch] $GetMeta,
        # Parameters
        [string] $SystemParams,
        [string] $FunctionParams
    )

    Log info "-GetMeta=$GetMeta -SystemParams='$SystemParams' -FunctionParams='$FunctionParams'"
    $function_params = ConvertFrom-Json2 $FunctionParams
    $system_params   = ConvertFrom-Json2 $SystemParams

    if ($GetMeta) {
        #
        # Get meta data
        #
        @{
            semantics = 'create'
            parameters = @( 
                @{ name = "StudentId"; allowance = 'mandatory' }
                @{ name = "AddressBeginDate"; allowance = 'optional' }
                @{ name = "AddressEndDate"; allowance = 'optional' }
                @{ name = "AddressTypeId"; allowance = 'mandatory' }
                @{ name = "AdmissionsRegionId"; allowance = 'optional' }
                @{ name = "City"; allowance = 'optional' }
                @{ name = "CountryId"; allowance = 'optional' }
                @{ name = "CountryName"; allowance = 'optional' }
                @{ name = "CountyId"; allowance = 'optional' }
                @{ name = "EmailAddress"; allowance = 'optional' }
                @{ name = "EmployerName"; allowance = 'optional' }
                @{ name = "FirstName"; allowance = 'optional' }
                @{ name = "FullName"; allowance = 'optional' }
                @{ name = "IsExcludedCrmIntegration"; allowance = 'optional' }
                @{ name = "IsSeasonalAddress"; allowance = 'optional' }
                @{ name = "LastName"; allowance = 'optional' }
                @{ name = "MobileNumber"; allowance = 'optional' }
                @{ name = "Note"; allowance = 'optional' }
                @{ name = "OtherEmailAddress"; allowance = 'optional' }
                @{ name = "OtherPhone"; allowance = 'optional' }
                @{ name = "PhoneNumber"; allowance = 'optional' }
                @{ name = "PlusReferenceNumber"; allowance = 'optional' }
                @{ name = "PostalCode"; allowance = 'optional' }
                @{ name = "PrintedOnMasterPromNote"; allowance = 'optional' }
                @{ name = "PrintedOnPlusPromNote"; allowance = 'optional' }
                @{ name = "SecondPhoneNumber"; allowance = 'optional' }
                @{ name = "SourceSystem"; allowance = 'optional' }
                @{ name = "Ssn"; allowance = 'optional' }
                @{ name = "State"; allowance = 'optional' }
                @{ name = "StreetAddress"; allowance = 'optional' }
                @{ name = "StreetAddress2"; allowance = 'optional' }
                @{ name = "StudentEnrollmentPeriodId"; allowance = 'optional' }
                @{ name = "TitleId"; allowance = 'optional' }
                @{ name = "WorkPhoneNumber"; allowance = 'optional' }
                @{ name = "YearsAtAddress"; allowance = 'optional' }
                @{ name = "YearsKnownStudent"; allowance = 'optional' }
                @{ name = '*';              allowance = 'prohibited' }
            )
        }
    }
    else {
        #
        # Execute function
        #
        
        # First Pull new Create / Empty record
        $params = @{
            URI = 'https://{0}/api/commands/Common/StudentRelationshipAddress/create' -f $system_params.tenantId
            Method = 'POST'
            Headers = @{
                    authorization = 'ApplicationKey {0}' -f $system_params.apiKey
                    accept = '*/*'
                    'Content-Type' = 'application/json; charset=utf-8'
                }
            TimeoutSec = 20
        }
        $response_create = Invoke-RestMethod @params
        $new_body = @{
            payload = $response_create.payload.data
        }

        # Prepare New Record.  Add values passed in from NIM.
        $function_params.GetEnumerator() | ForEach-Object {
            $new_body.payload.$($_.name) = $_.value
        }

        # Save new record
        $params.URI = 'https://{0}/api/commands/Common/StudentRelationshipAddress/saveNew' -f $system_params.tenantId
        $params.Body = $new_body | ConvertTo-Json -Depth 50

        $post_response = Invoke-RestMethod @params

        # Prepare and return data
        $l_properties = ($Global:Properties.'StudentRelationshipAddresses' ).name
        $hash_table = [ordered]@{}
        foreach ($column_name in $l_properties) {
            $hash_table[$column_name] = $post_response.payload.data.$column_name
        }
            
        #Log info ("Response: {0}" -f ($post_response | ConvertTo-Json -Depth 2 ))
        #Log info ("HashTable: {0}" -f ($hash_table | ConvertTo-Json -Depth 2 ))
        # Output new record.
        $hash_table
    }
    Log info ("Done")
}

###
#   Support Functions
###

function Get-OData {
    param (
        [switch] $GetMeta,
        [string] $SystemParams,
        [string] $FunctionParams,
        [string] $Class
    )
    Log info "-Class=$Class -GetMeta=$GetMeta -SystemParams='$SystemParams' -FunctionParams='$FunctionParams'"

    if ($GetMeta) {
        Get-ClassMetaData -SystemParams $SystemParams -Class $Class
    }
    else {
        
        $system_params   = ConvertFrom-Json2 $SystemParams
        $function_params = ConvertFrom-Json2 $FunctionParams

        $l_properties = $function_params.properties

        if ($l_properties.length -eq 0) {
            $l_properties = ($Global:Properties.$Class | Where-Object { $_.options.Contains('default') }).name
        }

        # Assure key is the first column
        $key = ($Global:Properties.$Class | Where-Object { $_.options.Contains('key') }).name
        $l_properties = @($key) + @($l_properties | Where-Object { $_ -ne $key })
        
        # Get Data from $Class
        $i = 0
        $data = [System.Collections.Generic.List[Object]]::new()
        do {
            Log info ("Retrieving {2} records {0} - {1}" -f $i, ($i+$system_params.pagesize), $Class)
            Write-Information ("Retrieving {2} records {0} - {1}" -f $i, ($i+$system_params.pagesize), $Class)
            $params = @{
                URI = 'https://{0}/ds/campusnexus/{1}?$skip={2}&$top={3}&$count=true' -f $system_params.tenantId,$Class,$i,$system_params.pagesize
                Method = 'Get'
                Headers = @{
                            authorization = 'ApplicationKey {0}' -f $system_params.apiKey; 
                            'Content-Type' = 'application/json; charset=utf-8'
                            accept = '*/*'
                        }
                TimeoutSec = 300
            }
            ## TODO:  Add ProxyLogic Here!  Based on System Parameters, and adding params for Invoke-RestMethod.
            $response = Invoke-RestMethod @params
            $data.AddRange([array]$response.value)
            $i += $response.value.count
        } while ($response.value.count -ge $system_params.pagesize)
        
        # Format data for return to NIM        
        $hash_table = [ordered]@{}
        foreach ($column_name in $l_properties) {
            $hash_table[$column_name] = ""
        }
        $obj_tmpl = New-Object -TypeName PSObject -Property $hash_table

        #$i = 0
        foreach($item in $data) {
            
            # 2024-03-15 - Turning off logic that rebuilds the objects to match the Property Definition.
            #              It is just too slow in PS 5.1.  In PS 7 would be able to do in parallel.
            
            #if($i++ % 100 -eq 0) { Log info ('Processing {0} of {1}' -f $i,$data.Count) }
            #$obj = $obj_tmpl.PSObject.Copy()
            
            #$l_properties.foreach( {
            #    $obj.$_ = $item.$_
            #} )
            # 
            #$obj
            
            $item
        }
    }

    Log info "Done"
}

function Get-ClassMetaData {
    param (
        [string] $SystemParams,
        [string] $Class
    )
    @(
        @{
            name = 'properties'
            type = 'grid'
            label = 'Properties'
            description = 'Selected properties'
            table = @{
                rows = @( $Global:Properties.$Class | ForEach-Object {
                    @{
                        name = $_.name
                        usage_hint = @( @(
                            foreach ($opt in $_.options) {
                                if ($opt -notin @('default', 'idm', 'key')) { continue }

                                if ($opt -eq 'idm') {
                                    $opt.Toupper()
                                }
                                else {
                                    $opt.Substring(0,1).Toupper() + $opt.Substring(1)
                                }
                            }
                        ) | Sort-Object) -join ' | '
                    }
                })
                settings_grid = @{
                    selection = 'multiple'
                    key_column = 'name'
                    checkbox = $true
                    filter = $true
                    columns = @(
                        @{
                            name = 'name'
                            display_name = 'Name'
                        }
                        @{
                            name = 'usage_hint'
                            display_name = 'Usage hint'
                        }
                    )
                }
            }
            value = ($Global:Properties.$Class | Where-Object { $_.options.Contains('default') }).name
        }
    )
}
