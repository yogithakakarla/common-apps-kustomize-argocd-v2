

Task :
1)A re-usable repo with standard structure which should suit to most of projects (if not all)
2)Use of Overlays to make it work with multiple envs
3)Use of kustomize to better manage resources
4)Each and every thing to be done with declarative approach - Yaml

So , As per the requirement , we need to deploy common applications and also applications on env wise using kustomize and argocd . so we have followed below folder structure 

base folder consists of  all applications 
overlays folder consists of common folder which can deploy all common applications in respective env  & also env wise folders to deploy only apps on respective env 

and we have helm chart folder which consists of argocdmanifest file which is dpeloyed using helm 

As part of dpeloying applications we have deployed normal applications with their kubernetes manifests files and also tried deploying remote helm charts as well as local helm charts 

.
├── base
│   ├── app-1
│   ├── app-2
│   ├── app-3
│   ├── app-4
│   ├── app-5
│   └── app-6
└── overlays
    ├── common
    │   ├── app-1
    │   │   ├── env-1
    │   │   └── env-2
    │   └── app-2
    │       ├── env-1
    │       └── env-2
    ├── env-1
    │   ├── app-3
    │   └── app-4
    └── env-2
        ├── app-5
        └── app-6
