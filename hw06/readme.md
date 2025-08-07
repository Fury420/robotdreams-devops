Cíl úkolu:
Naučit se základy práce s Kubernetes prostřednictvím nasazení jednoduchého
Nginx serveru pomocí Minikube na Linux systému.

Prerekvizity:
- Windows jsou možné, ale ukázky jsou pro Linux operační systém
(Ubuntu/CentOS/Fedora), MacOs
- Docker nainstalovaný a spuštěný
- Základní znalost práce s terminálem

Krok 1: Instalace Minikube
1.1 Stažení a instalace Minikube
```bash
# Stažení nejnovější verze Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-
linux-amd64
# Přejmenování a přesun do systémového adresáře
sudo install minikube-linux-amd64 /usr/local/bin/minikube
# Ověření instalace
minikube version
```

1.2 Instalace kubectl
```bash
# Stažení kubectl
curl -LO &quot;https://dl.k8s.io/release/$(curl -L -s
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl&quot;
# Nastavení práv a přesun
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
# Ověření instalace
kubectl version --client
```
1.3 Spuštění Minikube
```bash
# Spuštění Minikube clusteru
minikube start
# Ověření stavu clusteru
kubectl cluster-info
kubectl get nodes
```
Krok 2: Vytvoření Nginx Deployment
(kroky 2 a 3)
2.1 Vytvoření souboru nginx-deployment.yaml
Vytvořte soubor `nginx-deployment.yaml` s následujícím obsahem:
```yaml
apiVersion: apps/v1

kind: Deployment
metadata:
name: my-nginx
spec:
selector:
matchLabels:
run: my-nginx
replicas: 2
template:
metadata:
labels:
run: my-nginx
spec:
containers:
- name: my-nginx
image: nginx
ports:
- containerPort: 80
```
2.2 Nasazení Deployment
```bash
# Aplikace deployment
kubectl apply -f nginx-deployment.yaml
# Ověření deployment
kubectl get deployments
kubectl get pods

kubectl describe deployment my-nginx
```
Krok 3: Vytvoření Service s NodePort
3.1 Vytvoření souboru nginx-service.yaml
Vytvořte soubor `nginx-service.yaml` s následujícím obsahem:
```yaml
apiVersion: v1
kind: Service
metadata:
name: my-nginx
labels:
run: my-nginx
spec:
type: NodePort
ports:
- port: 80
protocol: TCP
targetPort: 80
nodePort: 30007
selector:
run: my-nginx
```
3.2 Nasazení Service
```bash
# Aplikace service

kubectl apply -f nginx-service.yaml
# Ověření service
kubectl get services
kubectl describe service my-nginx
```
Krok 4: Testování přístupu
4.1 Získání URL pro přístup
```bash
# Získání URL minikube service
minikube service my-nginx --url
# Nebo ruční sestavení URL
minikube ip
# URL bude: http://&lt;minikube-ip&gt;:30007
```
4.2 Testování v browseru a terminálu
```bash
# Test pomocí curl
curl http://$(minikube ip):30007
# Otevření v browseru
minikube service my-nginx
```
Krok 5: Ověření a monitoring
5.1 Kontrola stavu podů a služeb
```bash

# Zobrazení všech resources
kubectl get all
# Zobrazení logů z podů
kubectl logs -l run=my-nginx
# Popis konkrétního podu
kubectl describe pod &lt;pod-name&gt;
```
5.2 Debugging (pokud něco nefunguje)
```bash
# Kontrola events
kubectl get events --sort-by=.metadata.creationTimestamp
# Port-forward jako alternativa (pro testování)
kubectl port-forward service/my-nginx 8080:80
```
Úkoly k ověření
1. **Screenshot** - Poříďte screenshot browseru zobrazujícího Nginx welcome
page
2. **Výstup příkazů** - Zadokumentujte výstup těchto příkazů:
```bash
kubectl get pods
kubectl get services
kubectl get deployments
```
3. **Test škálování** - Upravte počet replik na 3 a ověřte změnu
4. **Cleanup** - Na konci úkolu vše vyčistěte pomocí:

```bash
kubectl delete -f nginx-service.yaml
kubectl delete -f nginx-deployment.yaml
```
Očekávané výsledky
Po úspěšném dokončení úkolu byste měli:
- Mít funkční Minikube cluster
- Běžící 2 nginx pods
- Přístupný nginx server přes NodePort na portu 30007
- Základní pochopení kubectl příkazů
Dodatečné zdroje
- Oficiální dokumentace Minikube
- Kubernetes Basics Tutorial
- kubectl Cheat Sheet