cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=demo sidecar-csr.json | cfssljson -bare sidecar

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=demo querier-csr.json | cfssljson -bare querier

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=demo storagegateway-csr.json | cfssljson -bare storagegateway

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=demo storegegateway-csr.json | cfssljson -bare storegegateway

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=demo storegateway-csr.json | cfssljson -bare storegateway

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=demo prometheus-csr.json | cfssljson -bare prometheus

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=demo receiver-csr.json | cfssljson -bare receiver