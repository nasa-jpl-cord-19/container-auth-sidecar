#!/usr/bin/env bash
set -e

APP_HOST=${APP_HOST:-localhost}
# I think this is fine to do because we're not storing any long term session information.
OIDC_CRYPTO_PASS="${OIDC_CRYPTO_PASS:-$(dd if=/dev/urandom count=1 bs=45 | base32)}"

cat << EOF > /usr/local/apache2/conf/site.conf
<VirtualHost *:80>
    ErrorDocument 200 "ok"
    RewriteEngine On
    RewriteRule "/fd888239-5bf8-4e6d-a523-f0ca5a34479c/status" - [R=200]

    OIDCProviderMetadataURL https://cognito-idp.${AWS_REGION}.amazonaws.com/${COGNITO_USER_POOL_ID}/.well-known/openid-configuration
    OIDCClientID ${COGNITO_USER_POOL_CLIENT_ID}
    OIDCClientSecret ${COGNITO_USER_POOL_CLIENT_SECRET}
    OIDCRedirectURI /example/redirect_uri
    OIDCCryptoPassphrase "${OIDC_CRYPTO_PASS}"
    OIDCOAuthVerifyJwksUri https://cognito-idp.${AWS_REGION}.amazonaws.com/${COGNITO_USER_POOL_ID}/.well-known/jwks.json

    <Location />
        AuthType oauth20
        <RequireAll>
            Require claim client_id:${COGNITO_USER_POOL_CLIENT_ID}
            Require valid-user
        </RequireAll>

        ProxyPass  "http://${APP_HOST}:${APP_PORT}/"
        ProxyPassReverse  "http://${APP_HOST}:${APP_PORT}/"
    </Location>
    
</VirtualHost>
EOF

exec httpd-foreground "$@"