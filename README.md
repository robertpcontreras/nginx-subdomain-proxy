# Nginx Subdomain Proxy

This docker container is responsible for routing requests that come into the docker network using the subdomain to direct the request to the appropriate service.

The rancher load balancer is responsible for accepting the request, ssl termination and forwarding the request to the proxy. This also gives us the ability to
scale the proxy container to reduce the load on individual proxy containers. 

The proxy routes requests by reading the subdomain of the url. It does this using using `map`, an nginx configuration block that allows us to perform a regular expression match on the url.

In this configuration the regular expressoin allows us to read the whole hostname as well as the
subdomain. These values are saved to the `$host` and `$subdomain` variables that we can then use within the server block of the nginx configuarion.

The server block is then responsible for catching all requests and then forwards them on to the relevant service within the docker network. The config can be seen below:

```
location / {
    resolver 127.0.0.11; # dockers internal DNS server
    
    if ($subdomain) {
        proxy_pass http://$subdomain:8080;
    }
    
    proxy_set_header Host            $host;
    proxy_set_header X-Real-IP       $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

The `customers` part is hardcoded and related to the stack that we will be putting all customers under within rancher. It is also hardcoded to port 8888 as this is the port exposed by the containers that are running the customer sites.

The resolver is the IP of the DNS service within the rancher network. It is responsible for resolving `$subdomain.customers` to the relevant IP of the customers container. When you upgrade a container, it may take a few minutes for the DNS to resolve to the new containers IP. This is sometimes instant, and sometimes takes 10 minutes.

