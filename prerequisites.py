#!/usr/bin/env python3

import argparse
import json
import subprocess
from time import sleep

# Configuring Arguments
def collect_args():
  parser = argparse.ArgumentParser(description="Prerequisites validation and configuration updation for Argo CD.")
  parser.add_argument('--argocd-namespace', type=str, action='store', help='Namespace in which Argo CD is either installed or to be installed. [Required]')
  args = parser.parse_args()

  if not args.argocd_namespace:
    parser.print_help()
    exit(1)
  
  return args

# Function to execute commands

def execute_command(command, k_get_command=False, exit_on_fail=False):
  result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
  print(result)
  returncode = result.returncode

  if k_get_command == False:
    if returncode == 0:
      output = result.stdout

    else:
      output = result.stderr
      print(f"Error: {result.stderr}")

      if exit_on_fail:
        exit(1)
  else:
    if result.stdout:
      returncode = 0
      output     = result.stdout
    elif result.stderr:
      returncode = 1
      output     = result.stderr
    else:
      returncode = result.returncode
      output     = ""
  return returncode, output

# Validations

def validate_kubectl():
  print('Validating kubectl CLI utility...')
  status, output = execute_command('kubectl version', exit_on_fail=False)

  if status != 0:
    print('kubectl is not installed. It has to be installed as a prerequisite for this exercise.')
    print('Validation failed.')
    exit(1)
  
  return True

def validate_argocd_installed(namespace):
  print(f'Validating Argo CD installation in {namespace} namespace...')
  status, output = execute_command(f'kubectl get pods -n {namespace}', k_get_command=True)
  
  if output.startswith('No resources found'):
    print(f'Argo CD is not installed in {namespace} namespace.')
    print('Argo CD Validation failed.')
    return False

  return True

def install_argocd(namespace):
  print(f'Installing Argo CD in {namespace} namespace...')
  status, output = execute_command(f'kubectl create ns {namespace}; kubectl apply -n {namespace} -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml')

  if status == 0:
    sleep(30)
    print('Installed Argo CD successfully.')
    print('Waiting while all the Argo CD pods come up [Timeout at 120 seconds]...')

    status, output = execute_command(f'kubectl wait pod --all -n {namespace} --timeout 120s --for condition=Ready')
    if status == 0:
      print('Argo CD is up and running now.')
      return True
    else:
      print('Argo CD pods did not come up. Please check.')

  else:
    print('Argo CD installation failed.')

  return False

def add_kustomize_options(namespace, kustomize_options):
  print(f"Checking if Kustomize Build Options are already present...")
  status,output = execute_command(f"kubectl get cm -n {namespace} argocd-cm -o yaml | yq '.data' | grep 'kustomize.buildOptions'", k_get_command=True)

  if status != 0:
    print("Kustomize Build Options are not present. Adding build options as provided")
    status, output = execute_command(f"""kubectl patch cm -n {namespace} argocd-cm --type=merge --patch='{{"data":{{"kustomize.buildOptions":"{kustomize_options}"}}}}'""")

    if status != 0:
      print('Could not add kustomize Build options.')
      print('Exiting...')
      exit(1)
  
  else:
    print('Following are the kustomize build options found:')
    print(output)

    existing_build_options = output.strip().lstrip('kustomize.buildOptions:').split()
    options_to_be_added    = list(set(kustomize_options.split()) - set(existing_build_options))
    all_options            = ' '.join(list(set(kustomize_options.split()) | set(existing_build_options)))

    if not options_to_be_added:
      print('All the options passed already exist.')
      return True

    else:
      status, output = execute_command(f"""kubectl patch cm -n {namespace} argocd-cm --type=merge --patch='{{"data":{{"kustomize.buildOptions":"{all_options}"}}}}'""")

      if status != 0:
        print('Could not update kustomize Build options.')
        print('Exiting...')
        exit(1)

def enable_progressive_sync(namespace):
  print("Enabling Progressive Sync...")
  status, output = execute_command(f"""kubectl patch cm -n {namespace} argocd-cmd-params-cm --type=merge --patch='{{"data":{{"applicationsetcontroller.enable.progressive.syncs":"true"}}}}'""")

  if status != 0:
    print("Could not enable progressive sync")
    print("Exiting...")
    exit(1)

  else:
    print("Enabled Progressive Sync")
    print("Restarting pods...")

    status, output = execute_command(f"kubectl rollout restart deployment -n {namespace} argocd-applicationset-controller argocd-redis argocd-repo-server argocd-server")

    if status != 0:
      print("Could not restart pods.")
      print("Please restart the following pods: argocd-applicationset-controller argocd-redis argocd-repo-server argocd-server argocd-application-controller")

    status, output = execute_command(f"kubectl rollout restart statefulset -n {namespace} argocd-application-controller")

    if status != 0:
      print("Could not restart pods.")
      print("Please restart the following pod: argocd-application-controller")

  return True


if __name__ == "__main__":

  # Args collection
  args = collect_args()

  # Flags
  kubectl_validated = False
  argocd_validated  = False
  argocd_installed  = False

  # Validations
  kubectl_validated = validate_kubectl()
  argocd_validated  = validate_argocd_installed(args.argocd_namespace)
  
  if kubectl_validated and argocd_validated:
    print('Validation successful.')
  elif kubectl_validated and not argocd_validated:
    print('kubectl has been validated, but Argo CD installation could not be validated.')
    print(f'Will install Argo CD in {args.argocd_namespace} namespace.')

  # Execution
  if not argocd_validated:
    argocd_installed = install_argocd(args.argocd_namespace)

  if argocd_validated or argocd_installed:
    add_kustomize_options(args.argocd_namespace, "--enable-helm")
    enable_progressive_sync(args.argocd_namespace)