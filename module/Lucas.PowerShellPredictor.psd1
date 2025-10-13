@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Lucas.PowerShellPredictor.dll'

    # Version number of this module.
    ModuleVersion = '0.1.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID = '8b5e5a1d-3c2f-4e9a-b7d6-1f8c3a2e5b4d'

    # Author of this module
    Author = 'Lucas Pimentel'

    # Company or vendor of this module
    CompanyName = 'Lucas Pimentel'

    # Copyright statement for this module
    Copyright = '(c) Lucas Pimentel. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell predictor module providing command-line suggestions via PowerShell prediction subsystem using argument completion.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.2'

    # Minimum version of the common language runtime (CLR) required by this module
    DotNetFrameworkVersion = '9.0'

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Predictor', 'CommandLine', 'Completion', 'PSReadLine', 'IntelliSense')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()
        }
    }
}
