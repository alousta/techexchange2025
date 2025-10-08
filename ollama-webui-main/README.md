
# Deploying Ollama and Open WebUI on OpenShift

This guide provides a comprehensive and tested method for deploying **Ollama** and **Open WebUI** in the same OpenShift project. This approach resolves common permission-related issues by correctly configuring storage and security contexts. The following steps are executed in a terminal CLI window in your device.

## Prerequisites

  * **OpenShift Cluster**: Access to an OpenShift cluster with permissions to create a new project and deploy applications.
  * **OpenShift CLI (oc)**: The OpenShift command-line tool installed and configured to connect to your cluster.

For Mac and Linux, run the following command to install the CLIs:
```bash
curl -sL https://ibm.biz/idt-installer | bash
```
```bash
sudo apt-get update
sudo apt-get install git
```
For Windows 10 Pro, run the following command as an administrator in PowerShell:
```bash
[Net.ServicePointManager]::SecurityProtocol = "Tls12"; iex(New-Object Net.WebClient).DownloadString('https://ibm.biz/idt-win-installer')
```
```bash
winget install -e --id Git.Git
```

clone the workshop repo.
```bash
git clone https://github.com/alousta/techexchange2025.git
cd techexchange2025/ollama-webui-main
```

Watch and follow the video oc.login.mp4 you just clone and downloaded it in your device to login into the openshift cluster via CLI (Command Line Interface)
-----

## Step 1: Create a Project and Find the Security Context

First, create a new project and then determine the allowed `fsGroup` value for that project. OpenShift uses this value to grant a pod's containers write access to mounted volumes. Add -YOURINITIALS-XX (where XX is your student number) at the end of the project name. For example, oc new-project ollama-webui-al.

### Create a new OpenShift project:

```bash
oc new-project ollama-webui
```

### Find the allowed fsGroup value:

The `fsGroup` is part of your project's security context. We can find the correct range by inspecting the project's annotations. But first, let's grant a specific user or service account elevated permissions. Specifically, we will assign the anyuid Security Context Constraint (SCC) to the default service account within the ollama-webui project or namespace.

```bash
oc adm policy add-scc-to-user anyuid -z default -n ollama-webui
```

```bash
oc get namespace ollama-webui -o jsonpath='{.metadata.annotations.openshift\.io\/sa\.scc\.supplemental-groups}'
```
The output will be a string like `1001020000/10000`. The number before the slash (`1001020000`) is the value you need. Copy this value.

-----

## Step 2: Prepare the Deployment YAML

Create a single YAML file named `ollama-openwebui.yaml`. This file contains all the necessary resources:

  * Persistent Volume Claims for Ollama (for models) and Open WebUI (for user data).
  * Ollama Deployment and Service, configured to use the correct `fsGroup` and environment variables.
  * Open WebUI Deployment, Service, and Route, configured to connect to Ollama using its internal service name.

Replace the placeholder `<YOUR_PROJECT_FSGROUP_VALUE>` in the YAML below with the number you found in the previous step.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: open-webui-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  labels:
    app: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      securityContext:
        fsGroup: <YOUR_PROJECT_FSGROUP_VALUE>
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        env:
        - name: HOME
          value: "/opt/ollama"
        - name: OLLAMA_MODELS
          value: "/opt/ollama/models"
        volumeMounts:
        - name: ollama-storage
          mountPath: /opt/ollama
      volumes:
      - name: ollama-storage
        persistentVolumeClaim:
          claimName: ollama-data
      nodeSelector:
        app: gpu-serving-node
---
apiVersion: v1
kind: Service
metadata:
  name: ollama-service
  labels:
    app: ollama
spec:
  ports:
  - port: 11434
    targetPort: 11434
  selector:
    app: ollama
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: open-webui
  labels:
    app: open-webui
spec:
  replicas: 1
  selector:
    matchLabels:
      app: open-webui
  template:
    metadata:
      labels:
        app: open-webui
    spec:
      securityContext:
        fsGroup: <YOUR_PROJECT_FSGROUP_VALUE>
      containers:
      - name: open-webui
        image: ghcr.io/open-webui/open-webui:main
        ports:
        - containerPort: 8080
        env:
        - name: OLLAMA_BASE_URL
          value: "http://ollama-service:11434"
        - name: WEBUI_SECRET_KEY
          value: "your_secret_key"
        - name: HOME
          value: "/app/backend/data"
        volumeMounts:
        - name: open-webui-storage
          mountPath: /app/backend/data
      volumes:
      - name: open-webui-storage
        persistentVolumeClaim:
          claimName: open-webui-data
      nodeSelector:
        app: gpu-serving-node
---
apiVersion: v1
kind: Service
metadata:
  name: open-webui-service
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: open-webui
  type: ClusterIP
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: open-webui-route
spec:
  to:
    kind: Service
    name: open-webui-service
  port:
    targetPort: 8080
```

-----

## Step 3: Deploy the Applications

Apply the YAML file to your OpenShift cluster. This will create all the defined resources simultaneously.

```bash
oc apply -f ollama-openwebui.yaml
```

-----

## Step 4: Verify and Access

### Check pod status:

Monitor the pods until they are all in the **Running** state.

```bash
oc get pods -w
```

### Get the Open WebUI URL:

Once the pods are running, find the URL for the Open WebUI application.

```bash
oc get route open-webui-route
```

The URL is listed in the `HOST/PORT` column. Make sure you add http:// plus your route name. 

### Access Open WebUI:

Open the URL in your web browser. You can now create your first user account and pull models directly from the UI. To pull a model like **Llama 3**, simply execute these sample command:

```bash
oc get po -l app=ollama -o jsonpath='{.items[0].metadata.name}' | xargs -I {} oc exec {} -- ollama pull tinyllama
```

```bash
oc get po -l app=ollama -o jsonpath='{.items[0].metadata.name}' | xargs -I {} oc exec {} -- ollama pull granite3.3
```

```bash
oc get po -l app=ollama -o jsonpath='{.items[0].metadata.name}' | xargs -I {} oc exec {} -- ollama pull deepseek-r1
```

### Start Part 2 on README.Part2.md

The next section covers how to ground documents to your LLM Assistant using a tecnique called Retrieval Augmented Generation (RAG). We will review MFT and B2B Use Cases.