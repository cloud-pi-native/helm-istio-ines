# helm-istio-ines

## Introduction

Ce HelmChart permet de configurer les éléments istio nécessaire au projet pour l'accès vers INES depuis l'un des clusters situé au ministère.

Le projet devra renseigner les valeurs correspondante afin de fournir son certificat d'accès a INES encrypté à l'aide de SOPS et [la commande présente dans la partie configuration](#encryption_du_secret).

Le projet pourra ensuite accèder a ines en utilisant http://**{{ines.host}}**/ sans avoir a gérer le MTLS de son coté celui-ci étant porté par istio.

## Configuration

### Encryption du secret

Pour encoder le secret il faudra utilisé la commande sops suivante avec la AGE_KEY correspondante au cluster de déployement et renseigner le **secretValue** en copiant **A PARTIR DE DATA** les informations comme le nom etc seront généré dynamiquement par le helmChart

```
sops -e --age $AGE_KEY --encrypted_regex (crt|key) myinescert.yaml > myinescert.yaml.enc.yaml
```

### Helm values

| Parameter          | Description                                     | Default          |
| ------------------ | ----------------------------------------------- | ---------------- |
| `ines.name`        | Surcharge du nom pour identifier les ressources | `ines-myprj-dev` |
| `ines.host`        | hostname d'accès vers INES                      | `ines.dev.mi.fr` |
| `ines.secretValue` | contenu du SopsSecret à partir de **data**      | `data: ...`      |
