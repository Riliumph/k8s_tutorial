aws-login() {
    local token

    if [ -z "$AWS_MFA_ARN" ]; then
        echo "Usage: aws-login <mfa-arn>"
        return 1
    fi

    read -p "MFA Code: " token

    local creds
    creds=$(aws sts get-session-token \
            --serial-number "${AWS_MFA_ARN}" \
            --token-code "${token}" \
            --output json)

    local expiration
    expiration=$(echo "$creds" | jq -r '.Credentials.Expiration')
    export AWS_ACCESS_KEY_ID=$(echo "$creds" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$creds" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$creds" | jq -r '.Credentials.SessionToken')

    echo "AWS session credentials have been exported."
    echo "ACCESS KEY   : ${AWS_ACCESS_KEY_ID}"
    echo "SECRET KEY   : ${AWS_SECRET_ACCESS_KEY}"
    echo "SESSION TOKEN: ${AWS_SESSION_TOKEN}"
    echo "Expires at   : $expiration"

}
