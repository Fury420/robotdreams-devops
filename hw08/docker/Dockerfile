FROM nginx:alpine

# Kopírování vlastního index.html souboru
COPY ./app/index.html /usr/share/nginx/html/index.html

# Vytvoření prázdného favicon.ico aby se předešlo 404 chybě
RUN touch /usr/share/nginx/html/favicon.ico

# Expozice portu 80
EXPOSE 80

# Spuštění Nginx
CMD ["nginx", "-g", "daemon off;"]
