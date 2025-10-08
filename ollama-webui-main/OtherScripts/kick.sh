oc delete project ollama-webui
oc new-project ollama-webui
oc adm policy add-scc-to-user anyuid -z default -n ollama-webui
oc create -f pvc.yml
sleep 10
oc create -f ollama-deployment.yml
oc create -f open-webui-deployment.yml
oc get po -w

