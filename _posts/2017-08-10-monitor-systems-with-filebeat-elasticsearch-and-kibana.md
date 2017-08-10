---
title: Monitor your systems with Filebeat, Elasticsearch and Kibana on Debian 9 (Stretch)
layout: default
tags:
 - Linux
 - Debian
 - Monitoring
 - Elasticsearch
 - Filebeat
 - Kibana
 - X-Pack
 - TLS
---

Most of the install instructions are taken from [this page](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html) and in the official Elasticsearch documentation and [that page](https://www.elastic.co/guide/en/beats/libbeat/5.5/getting-started.html) in the Beats documentation.

To keep individual services as isolated as possible, I recommend to configure the Elasticsearch and Kibana server in one or even two dedicated LXC containers. How to create new LXC containers, see the post on [Creating LXC containers using host-shared NAT bridge]({% post_url 2017-08-02-LXC-with-NAT-bridge %}).


Setup Elasticsearch server
--------------------------

* Install prerequisites:
```shell
$ apt update && apt install curl unzip gnupg2 apt-transport-https
```

* Install Java:
```shell
apt install openjdk-8-jre
```
   * You may run into this error:
   ```
   The following packages have unmet dependencies:
        openjdk-8-jre : Depends: openjdk-8-jre-headless (= 8u131-b11-1~bpo8+1) but it is not going to be installed
   E: Unable to correct problems, you have held broken packages.
   ```
      * If that's the case, then run the following:
   ```shell
   $ apt install -t jessie-backports openjdk-8-jre-headless ca-certificates-java
   ```

* Add Elasticsearch repository and install:
```shell
$ curl https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
$ echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
$ apt update && apt install elasticsearch kibana
```

### Install X-Pack Plugin

Instructions are taken from the [official X-Pack installation documentation page](https://www.elastic.co/guide/en/x-pack/current/installing-xpack.html).


* For Elastiksearch:
```shell
$ cd /usr/share/elasticsearch/
$ bin/elasticsearch-plugin install x-pack
```

* For Kibana:
```shell
$ cd /usr/share/kibana/
$ bin/kibana-plugin install x-pack
```


### Enable SSL/TLS on Elasticsearch server

The following steps are based on [this official X-Pack documentation page](https://www.elastic.co/guide/en/x-pack/5.2/ssl-tls.html#configure-ssl).

* Create file `/etc/elasticsearch/x-pack/instances.yml` and list all DNS names and IP addresses you want the host to be reachable on:

   ```shell
   instances:
     - name: "elasticsearch"
       ip:
         - "127.0.0.1"
         - "11.22.33.44"
       dns:
         - "localhost"
         - "elasticsearch.example.com"
    ```

* Generate certificate(s) as defined in the YAML file above:
   ```shell
   $ cd /usr/share/elasticsearch
   $ bin/x-pack/certgen -in /etc/elasticsearch/x-pack/instances.yml --out /etc/elasticsearch/x-pack/certificate-bundle.zip
   ```
   * If the above command crashes, simply re-run.
   * If you have a pre-existing CA certificate and key and want to re-use it, use this instead:
      ```shell
      $ bin/x-pack/certgen --in /etc/elasticsearch/x-pack/instances.yml --out /etc/elasticsearch/x-pack/certificate-bundle.zip --cert /etc/elasticsearch/x-pack/ca/ca.crt --key /etc/elasticsearch/x-pack/ca/ca.key
      ```

* Unzip certificate and key:
```shell
$ cd /etc/elasticsearch/x-pack/
$ unzip certificate-bundle.zip
```

* Add the following at the end of the file `/etc/elasticsearch/elasticsearch.yml` :
```
# added by ADMIN:
xpack.ssl.key: /etc/elasticsearch/x-pack/elasticsearch/elasticsearch.key
xpack.ssl.certificate: /etc/elasticsearch/x-pack/elasticsearch/elasticsearch.crt
xpack.ssl.certificate_authorities: [ "/etc/elasticsearch/x-pack/ca/ca.crt" ]
xpack.security.transport.ssl.enabled: true
xpack.security.http.ssl.enabled: true
```

* Copy CA certificate to Kibana configuration directory:
```shell
$ cp /etc/elasticsearch/x-pack/ca/ca.crt /etc/kibana/ca.crt
```

* Add the following to file `/etc/kibana/kibana.yml` :
```
# added by ADMIN:
elasticsearch.url: "https://localhost:9200"
elasticsearch.ssl.certificateAuthorities: [ "/etc/kibana/ca.crt" ]
```

### Enable and start Elasticsearch and Kibana servers

* Enable Debian services:
```shell
$ systemctl enable elasticsearch
$ systemctl enable kibana
```

* Start Debian services:
```shell
$ service elasticsearch restart
$ service kibana restart
```

### Change default passwords

* Connect with a browser to `localhost:5601` and log in as user `elastic` with password `changeme`

* Got to menu **Management->Users** and change passwords for all following users:
   * `elastic`
   * `kibana`
   * `logstash_system`

* Add following to the file `/etc/kibana/kibana.yml` :
```
elasticsearch.password: YOUR-PASSWORD-OF-USER-kibana
```

* Disable default passwords by adding the following to file `/etc/elasticsearch/elasticsearch.yml` :
```
xpack.security.authc.accept_default_password: false
```

* Restart Debian services:
```shell
$ service elasticsearch restart
$ service kibana restart
```


### Make Elasticsearch and Kibana reachable from outside localhost

* Add the following to file `/etc/elasticsearch/elasticsearch.yml` :
```
# make Elasticsearch available on all interfaces
network.host: 0.0.0.0
transport.host: localhost
```

* Add the following to file `/etc/kibana/kibana.yml` :
```
# make Kibana available on all interfaces:
server.host: "0.0.0.0"
```

* Restart Debian services:
```shell
$ service elasticsearch restart
$ service kibana restart
```


### Prepare Elasticsearch to accept input from Filebeat

This section is based on the [official X-Pack documentation on setting up Filebeat](https://www.elastic.co/guide/en/cloud-enterprise/current/users-manage-x-pack.html#security-filebeat-example).

* In Kibana, navigate to **Management->Roles**
* Click on **Create Role**
* Give it the **Name** `filebeat_writer`
* Select the following **Cluster Privileges**:
   * `monitor`
   * `manage_index_templates`
   * `manage_ingest_pipelines`
* Under **Index Priviliges**
   * Add `filebeat-*` under **Indices**
   * Add all of the following under **Priviliges**
      * `read`
      * `write`
      * `index`
      * `create_index`
* Click **Save**


Add client for monitoring on Elasticsearch
------------------------------------------

### Add new user on Elasticsearch server

* Log into Kibana with your browser and add a new user (e.g. `filebeat-user-machine-1` with password `filebeat-user-machine-1-password`) and select `filebeat_writer` under **Roles**.


### Install Filebeat on client you want to monitor

This section is based on the official [Filebeat documentation pages](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html).

* Install prerequisites:
```shell
$ apt update && apt install curl apt-transport-https
```

* Add Elasticsearch repository and install Filebeat:
```shell
$ curl https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
$ echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
$ apt update && apt install filebeat
```

* Copy CA certificate file `/etc/elasticsearch/x-pack/ca/ca.crt` from Elasticsearch server as file `/etc/filebeat/ca.crt` onto client

* Add the following to file `/etc/filebeat/filebeat.yml` under section `output.elasticsearch` :
```
output.elasticsearch:
     # Array of hosts to connect to.
     # modified by ADMIN:
     hosts: ["elasticsearch.example.com:9200"]

     # added by ADMIN:
     protocol: "https"
     username: "filebeat-user-machine-1"
     password: "filebeat-user-machine-1-password"
     ssl.certificate_authorities: ["/etc/filebeat/ca.crt"]
```

* Add the following at the end of file `/etc/filebeat/filebeat.yml` :
   ```
   # added by ADMIN:
   #name: choose-a-name-here-if-you-dont-want-it-to-be-your-hostname
   #==========================  Modules configuration ============================
   filebeat.modules:
   # to enable these modules, see next section
   #   - module: system
   #   - module: nginx
   ```

* Startup of the Elasticsearch server may take a minute or so. Therefore, if the Filebeat server is restarted at the same time as the Elasticsearch server, it will fail to connect to the Elasticsearch server and not start up. Thus we tweak the Filebeat `systemd` configuration to retry startup of the `filebeat` service.

  * Make sure the following lines are present in the `[Service]` section of file `/etc/systemd/system/multi-user.target.wants/filebeat.service` :
```
Restart=always
RestartSec=15
```
  * Reload `systemd`:
```shell
systemctl daemon-reload
```

* Enable and start Filebeat Debian service:
```shell
systemctl enable filebeat
service filebeat restart
```

* Check if Filebeat startup was successful:
```shell
cat /var/log/filebeat/filebeat
```

#### Enable System Monitoring

This section is based on the [official Filebeat documentation](https://www.elastic.co/guide/en/beats/filebeat/current/_tutorial.html).

* On the Elasticsearch *server*, run the following:
```shell
cd /usr/share/elasticsearch/
bin/elasticsearch-plugin install ingest-geoip
service elasticsearch restart
```

* On the monitored machine, add the `system` module in the `filebeat.modules` section in file `/etc/filebeat/filebeat.yml` :
   ```shell
   filebeat.modules:
       - module: system
   ```

* Restart Filebeat Debian service:
```shell
service filebeat restart
```

* Check if Filebeat startup was successful:
```shell
cat /var/log/filebeat/filebeat
```

