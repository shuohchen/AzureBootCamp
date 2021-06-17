#Switch to window containers on local
Enable-WindowsOptionalFeature -Online -FeatureName $("Microsoft-Hyper-V", "Containers") -All

#Go to the directory which has the docker file
cd "C:\Users\shuohchen.FAREAST\OneDrive - Microsoft\Documents 1\MyProjects\AzureBootCamp\Introduction_To_Container\studentfiles"

#check images you have
docker images

#build the image based on the dockerfile 
docker build -t contoso/ads-support .

#run the container
docker run -d --name testcontainer contoso/ads-support

#look at the running containers 
docker ps 

#inspect the IP address of the web app in the container
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" testcontainer

#login azure container registry, e.g.docker login <login server> -u <username> -p <password>
docker login shuohchencontainerregistry.azurecr.io -u shuohchencontainerregistry -p 5/9Q9i6jy8QopMHFSzekTj0iOXXTSJq1

#tag the container with the registry path
docker tag contoso/ads-support shuohchencontainerregistry.azurecr.io/contoso/ads-support

#push the container image
docker push shuohchencontainerregistry.azurecr.io/contoso/ads-support
