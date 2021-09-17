#!/bin/sh

platform="Carthage"
api_key=""
folder="$(pwd)/$(date +%F)" #TODO: fix this --> we probably need to create directory first!
#folder="$(pwd)"
force=false
print_help=false
max_page=-1
graphifypath="./GraphifyEvolution"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -p|--platform)
      platform="$2"
      shift # past argument
      shift # past value
      ;;
    -a|--api_key)
      api_key="$2"
      shift # past argument
      shift # past value
      ;;
    -f|--folder)
      folder="$2"
      shift # past argument
      shift # past value
      ;;
    --force)
      force=true
      shift # past argument
      ;;
    -m|--max)
      max_page="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      print_help=true
      shift # past argument
      ;;
    -g|--graphifypath)
      graphifypath="$2"
      shift # past argument
      shift # past value
      ;;
 #   --default)
 #     DEFAULT=YES
 #     shift # past argument
 #     ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$print_help" = true ]; then
 echo "-p / --platform  =  Platform to search projects from, default = Carthage"
 echo "-a / --api_key   =  API key to be used with libraries.io"
 echo "-f / --folder    =  folder where json files are written, default = <current path>/<current date>/"
 echo "-h / --help      =  Print help"
 echo "-m / --max       =  maximum number of pages to go through"
 echo "--force          =  force json file overwrite"
 echo "--help           =  print help"
 echo "-g / --graphifypath = Path to GraphifyEvolution instance, default is ./GraphifyEvolution"
 exit
fi

echo "[*] Starting library analysis"

echo "[*] Checking if GraphifyEvolution path is correct"
echo "command -v $graphifypath ]"
if [ $(command -v "$graphifypath") ]; then
  echo "[i] GraphifyEvoltuion path is correct."
else
  echo "[!] GraphifyEvolution not found on path $graphifypath"
  echo "[*] Exiting program."
  exit
fi

echo "[i] Searching for libraries on platform: $platform"
echo "[i] Saving all json results to: $folder"

page=0

echo "[*] Creating folder $folder"
mkdir $folder

while [ true ]
do
  page=$((page+1))
  
  if [ $max_page -gt 0 ]; then
    if [ $page -gt $max_page ]; then
        echo "[*] Stopping program, maximum page count $max_page"
        break
    fi
  fi
  
  file_name="$folder/libraries-$page.json"
    
  echo "[*] Fetching projects on page: $page"
  echo "[*] Checking if file $file_name already exists"

  if [ -f "$file_name" ]; then
    echo "[i] File $file_name already exists"
    
    if [ $force = false ]; then
       echo "[*] Skipping page $page"
       continue
    fi
    
    echo "[*] Overriding file $file_name, --force is enabled"
  fi
  
  echo "[*] Making request to: https://libraries.io/api/search?platforms=$platform&api_key=$api_key&page=$page&per_page=10"
  echo "[*] Saving results to: $file_name"
  
  http_code=$(curl --write-out "%{http_code}\n" "https://libraries.io/api/search?platforms=$platform&api_key=$api_key&page=$page&per_page=10" --output $file_name --silent)
  echo "[*] Http result code: $http_code"
  
  if [ "$http_code" = "404" ]; then
    echo "[*] Stopping program, page $page not found"
    break
  fi
  
  echo "[*] Running GraphifyEvolution"
  
  project_folder="$folder/libraries/$page/"
  echo "[*] Creating folder if it does not exist: $project_folder"
  echo "[i] Downloading projects into folder: $project_folder"
  
  # Usage: application analyse <path> [--app-key <app-key>] [--evolution] [--no-source-analysis] [--only-git-tags] [--bulk-json-path <bulk-json-path>] [--start-commit <start-commit>] [--language <language>] [--external-analysis <external-analysis> ...] [--dependency-manager <dependency-manager>]
  "$graphifypath" analyse "$project_folder" --evolution --bulk-json-path "$file_name" --no-source-analysis --external-analysis dependencies --only-git-tags
done


