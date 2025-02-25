FROM nginx:latest

# Directorio de trabajo
WORKDIR /etc/nginx

# Copiar los archivos HTML al directorio de Nginx
COPY index.html /usr/share/nginx/html/index.html
COPY features.html /usr/share/nginx/html/features.html

# Crear directorio para certificados y autenticación
RUN mkdir -p /etc/nginx/certs /etc/nginx/auth

# Generar certificado autofirmado
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/nginx.key \
    -out /etc/nginx/certs/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=localhost"

# Copiar la configuración de Nginx
RUN apt-get update && apt-get install -y python3-pip && \
    pip install jinja2-cli markupsafe

COPY nginx.conf.j2 /tmp/nginx.conf.j2

RUN jinja2 /tmp/nginx.conf.j2 -D VAR1=value1 -D VAR2=value2 > /etc/nginx/nginx.conf

# Generar usuario para autenticación básica
RUN apt-get update && apt-get install -y apache2-utils && \
    htpasswd -bc /etc/nginx/auth/.htpasswd usuario password123

# Exponer el puerto HTTPS
EXPOSE 443

# Comando de inicio
CMD ["nginx", "-g", "daemon off;"]
