# jenkins-ci
Pre-configured stateless jenkins

## How to boot it (k8s)
Create your desired casc configs and a "seed" job in a config map
```yaml 
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins
  namespace: cicd
data:
  jenkins_bootstrap.yml: "YAML Config for casc"
  seed.groovy: "DSL Seed job"
```
Create some secrets that are to be mounted into the container.
```bash
kubectl create secret generic jenkins --from-file=adminpass=jp.txt --from-file=repokey=jenkins_deploy -n cicd
```
Create the deployment and map in those data objects off the map, wire in the
Mandatory vars like `JAVA_OPTS` and `CASC_JENKINS_CONFIG` etc.
```yaml
containers:
  - name: jenkins
    image: theshipyard/jenkins-ci:0.0.7
    imagePullPolicy: Always
    env:
      - name: "JAVA_OPTS"
        value: "-Xms1024m -Xmx1024m -Djenkins.install.runSetupWizard=false"
      - name: "CASC_JENKINS_CONFIG"
        value: "/tmp/bootstrap/jenkins_bootstrap.yml"
      - name: "JENKINS_ADMIN_PASSWORD_HASH"
        valueFrom:
          secretKeyRef:
            name: jenkins
            key: adminpass
      - name: "REPO_KEY"
        valueFrom:
          secretKeyRef:
            name: jenkins
            key: repokey
      - name: "CR_USER"
        valueFrom:
          secretKeyRef:
            name: jenkins
            key: cruser
      - name: "CR_PASS"
        valueFrom:
          secretKeyRef:
            name: jenkins
            key: crpass
    ports:
      - containerPort: 8080
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1024Mi"
        cpu: "1000m"
    volumeMounts:
      - name: jenkins-config
        mountPath: /tmp/bootstrap
        readOnly: true
```
I'll leave the `service` and `ingress` stuff out of here for brevity but you know what
to do.

## Customizing the deployment
The image can be customized either prior to build via the plugins.txt to
"bake in" plugins speeding up startup in k8s.  Or you can use CASC to install additional 
plugins at jenkins startup.
