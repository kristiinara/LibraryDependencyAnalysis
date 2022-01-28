# LibraryDependencyAnalysis
Bulk analysis of third party library dependencies for Carthage, Swift Package Manager and CocoaPods

The analyse_library_dependencies.sh allows analysis of all libraries that are provided through Carthage, Swift Package Manager and CocoaPods. The script can be run with the following arguments: 

    -p / --platform  =  Platform to search projects from, default = Carthage
    -a / --api_key   =  API key to be used with libraries.io
    -f / --folder    =  folder where json files are written, default = <current path>/<current date>/
    -h / --help      =  Print help
    -m / --max       =  maximum number of pages to go through
    -o / --offline   =  use psql database instead of libraries.io to query projects
    --per_page       =  results per page, default = 1
    --podspecpath    =  path to cocoapods Podspec repository, if the folder does not exist then script will clone podspec repo there
    --force          =  force json file overwrite
    --temp           =  only store repos temporarily, remove them after they have been analysed
    --help           =  print help
    -g / --graphifypath = Path to GraphifyEvolution instance, default is ./GraphifyEvolution
  
Data about which projects to analyse can be either queried from a postgresql database (prerequisite is importing the projects table from libraries.io) or it can be extracted from the CocoaPods Spec repository for CocoaPods libraries. 

# Data description

When GraphifyEvolution is run on these projects (the script uses the option of no source analysis and only analysing versions with git tags) the following data is entered into the database: 

## Project
Data on projects that have been analysed. 

- "successfullyAnalysed": Boolean (if project was successfully analysed),
- "source": String (repository address),
- "failed": Boolean (if analysis of project failed),
- "title": String (name of project, of the form "username/projectname"),
- "analysisStarted": Boolean (if analysis was started),
- "analysisFinished": Boolean (if analysis was finished)

## App
Data on specific project versions that have been analysed. 

- "author": String (author information from git),
- "tree": String (git tree value),
- "commit": String (git commit value),
- "version_number": Int (n-th version of this project),
- "message": String (git commit message),
- "branch": String (git branch),
- "author_timestamp": String (author timestamp from git),
- "name": String (project name of the form "username/projectname"),
- "time": String (time of commit),
- "tag": String (git tag),
- "parent_commit": String (git parent commit, if analysis only includs tags, commit of parent tag),
- "timestamp": String (git commit timestamp)

## Library
Data on library versions. Can either be analysed and connected to App or just dependencies. 

- "name": String (either of the form "username/projectname or just projectname if the library has not been analysed or correctly matched)",
- "version": String (version number)
- "cpe": String (corresponding cpe in the NVD cpe dictionary or nil if there is none)

## LibraryDefinition
Library definitions from package manager manifest fils. 

- "name": String (name of library),
- "version": String (version including version constraint, for example "~> 3.2")

## Vulnerability
Vulnerability data queried from NVD. All impact data is from V3BaseMetric. 

- "availabilityImpact": String
- "description": String,
- "privilegesRequired": String
- "baseScore": Float, 
- "baseSeverity": String,
- "userInteractionRequired": String,
- "relatedCPE": String,
- "confidentialityImpact": String,
- "scope": String,
- "attackComplexity": String,
- "attackVector": String,
- "integrityImpact": String,
- "publishedDate": String,
- "id": String,
- "vectorString": String

# Relationships

- Project HAS_APP App
- App IS Library
- App DEPENDS_ON Library
- App DEPENDS_ON_INDIRECTLY Library
- App DEPENDS_ON LibraryDefinition
- Library HAS_VULNERABILITY Vulnerability

The following relationships have properties: 

## DEPENDS_ON and DEPENDS_ON_INDIRECTLY

- "type": String (either carthage, cocoapods or swiftpm, depending on through which package manager the dependency was integrated)


