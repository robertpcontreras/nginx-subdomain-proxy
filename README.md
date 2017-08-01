# Nginx Subdomain Proxy

This docker container is responsible for routing requests that come into the docker network using 
the subdomain to direct the request to the appropriate service.

The proxy routes requests by reading the subdomain of the url. It does this using using `map` block
in the nginx configuration that allows us to perform a regular expression match on the request uri.
The block below shows how this is done.

```
map $host $subdomain {
    ~^(?<sub>\w+).+$ $sub;
}
```

In this configuration the regular expressoin allows us to read the subdomain which we can then
store in a new variable, `$subdomain`, that can be used later in the configuration file.

The server block is then for catches all requests and then forwards them to the relevant service
within the docker network while retaining the correct protocol and port that we received the 
request to. The config can be seen below:

```
location / {
    resolver 127.0.0.11;

    if ($https = on) {
        proxy_pass https://$subdomain:$server_port;
    }

    if ($https != on) {
        proxy_pass http://$subdomain:$server_port;
    }
    
    proxy_set_header Host            $host;
    proxy_set_header X-Real-IP       $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

The resolver is the IP of the DNS service within the docker network, this is always `127.0.0,11`. 
It is responsible for resolving `$subdomain` to the relevant IP of the customers container.

