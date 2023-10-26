# helm-istio-ines

## Introduction

Ce HelmChart permet de configurer les éléments istio nécessaire au projet pour l'accès vers INES depuis l'un des clusters situé au ministère.

Le projet devra renseigner les valeurs correspondante afin de fournir son certificat d'accès a INES encrypté à l'aide de SOPS et [la commande présente dans la partie configuration](#encryption_du_secret).

Le projet pourra ensuite accèder a ines en utilisant http://**{{ines.host}}**/ sans avoir a gérer le MTLS de son coté celui-ci étant porté par istio.

## Configuration

### Encryption du secret

Pour encoder le secret il faudra utilisé la commande sops suivante avec la AGE_KEY correspondante au cluster de déployement et renseigner le **secretData** et **secretSops** en récupérant la partie **data** et **sops** du sopssecret généré les informations comme le nom etc seront généré dynamiquement par le helmChart

```
sops -e --age $AGE_KEY --encrypted_regex (crt|key) myinescert.yaml > myinescert.yaml.enc.yaml
```

### Ajout du sidecar istio

Afin de pouvoir communiqué avec l'egress gateway d'istio, un sidecar devra être à vos déployement necessitant l'utilisation d'INES.
Pour cela l'ajout du label `sidecar.istio.io/inject: "true"` sera necessaire ainsi que l'utilisation d'un serviceAccount spécifique `serviceAccount: istio-sa`.

Exemple d'ajout du sidecar :

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        sidecar.istio.io/inject: "true"
        app: nginx
        env: dev
        tier: frontend
    spec:
      serviceAccount: istio-sa
      serviceAccountName: istio-sa
      containers:
        - name: nginx
          image: bitnami/nginx:1.25.3
          ports:
            - containerPort: 8080
          resources:
            limits:
              cpu: 50m
              memory: "128Mi"
            requests:
              cpu: 5m
              memory: "128Mi"
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 60
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /
              port: 8080
              scheme: HTTP
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
```

### Helm values

| Parameter         | Description                                     | Default          |
| ----------------- | ----------------------------------------------- | ---------------- |
| `ines.name`       | Surcharge du nom pour identifier les ressources | `ines-myprj-dev` |
| `ines.host`       | hostname d'accès vers INES                      | `ines.dev.mi.fr` |
| `ines.secretData` | contenu du SopsSecret à partir de **data**      | `data: ...`      |
| `ines.secretSops` | contenu du SopsSecret à partir de **sops**      | `sops: ...`      |
