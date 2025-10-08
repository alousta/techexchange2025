#welcomeTechExchange2025
htpasswd -B -c htpasswd <username>
oc create secret generic htpasswd-secret --from-file=htpasswd --namespace openshift-config
oc patch oauths.config.openshift.io cluster --type=merge -p '{"spec":{"identityProviders":[{"htpasswd":{"fileData":{"name":"htpasswd-secret"}},"name":"htpasswd-provider","mappingMethod":"lookup","type":"HTPasswd"}]}}'
oc adm policy add-cluster-role-to-user cluster-admin <username>