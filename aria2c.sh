#!/bin/bash -eu

echo "Run aria2c and ariaNG"

if [ -n "$BASE64_RPC_SECRET" ]; then
    sed -i 's/,secret:"[^"]*",/,secret:"'${BASE64_RPC_SECRET}'",/' /usr/local/www/aria2/index.html
    sed -i 's/,rpcHost:"[^"]*",/,rpcHost:"'${RPC_HOST}'",/' /usr/local/www/aria2/index.html
    sed -i 's/,rpcPort:"[^"]*",/,rpcPort:"'${RPC_PORT}'",/' /usr/local/www/aria2/index.html
fi


ARIA2C_ARGS="--conf-path=${ARIA2_CONF} -D --enable-rpc --rpc-listen-all"

if [ -n "${RPC_CERTIFICATE}" ]; then
    ARIA2C_ARGS="${ARIA2C_ARGS} --rpc-certificate=${RPC_CERTIFICATE}"
    ARIA2C_ARGS="${ARIA2C_ARGS} --rpc-private-key=${RPC_PRIVATE_KEY}"
    ARIA2C_ARGS="${ARIA2C_ARGS} --rpc-secure"
    sed -i 's/,protocol:"http",/,protocol:"https",/' /usr/local/www/aria2/index.html
fi

if [ -n "${RPC_SECRET}" ]; then
    ARIA2C_ARGS="${ARIA2C_ARGS} --rpc-secret=${RPC_SECRET}"
fi

#/usr/bin/aria2c ${ARIA2C_ARGS} && caddy -quic --conf ${CADDY_FILE}
/usr/bin/aria2c ${ARIA2C_ARGS} && caddy --conf ${CADDY_FILE}
