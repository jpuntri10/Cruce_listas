FROM rocker/r-ver:4.3.1

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    unixodbc unixodbc-dev wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Instalar Oracle Instant Client (básico + ODBC)
WORKDIR /opt/oracle
RUN wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linux.x64-21.13.0.0.0dbru.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-odbc-linux.x64-21.13.0.0.0dbru.zip \
    && unzip instantclient-basiclite-linux.x64-21.13.0.0.0dbru.zip \
    && unzip instantclient-odbc-linux.x64-21.13.0.0.0dbru.zip \
    && rm *.zip \
    && cd instantclient_21_13 \
    && echo /opt/oracle/instantclient_21_13 > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig \
    && ./odbc_update_ini.sh /usr/local/etc/odbcinst.ini

# Variables de entorno para Oracle
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_21_13
ENV PATH=$LD_LIBRARY_PATH:$PATH

# Instalar paquetes R
RUN R -e "install.packages(c('shiny','readxl','dplyr','RODBC','DT','writexl'))"

# Copiar todo el proyecto al contenedor
COPY . /app
WORKDIR /app

# Ejecutar la app Shiny
CMD ["R", "-e", "shiny::runApp('/app', port=as.numeric(Sys.getenv('PORT')), host='0.0.0.0')"]
