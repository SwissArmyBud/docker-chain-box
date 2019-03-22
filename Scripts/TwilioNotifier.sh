param([string]$text = "This is your Twilio cURLer checking in!")

#####
# TWILIO API CURLER
#####

# Values from Twilio API site, see:
# https://www.twilio.com/docs/usage/api#authenticate-with-http
# Set from environment, don't leak tokens!
$TWILIO_API_TOKEN = $TWILIO_SECRET_TOKEN
$TWILIO_FROM_NUM = $TWILIO_SECRET_FROM
$TWILIO_TO_NUM = $TWILIO_SECRET_TO
$TWILIO_API_SID = $TWILIO_SECRET_SID
$TWILIO_API_VERSION = "2010-04-01"


if(($TWILIO_API_SID) -and ($TWILIO_API_TOKEN) -and ($TWILIO_TO_NUM) -and ($TWILIO_FROM_NUM)){

    # Notify on finish
    # Twilio API endpoint and POST params
    $WR_URL = "https://api.twilio.com/$TWILIO_API_VERSION/Accounts/$TWILIO_API_SID/Messages.json"
    $WR_PARAMS = @{ To = $TWILIO_TO_NUM; From = $TWILIO_FROM_NUM; Body = $TEXT }

    # Create a credential object for HTTP basic auth
    $GEN_TOKEN = $TWILIO_API_TOKEN | ConvertTo-SecureString -asPlainText -Force
    $WR_CRED = New-Object System.Management.Automation.PSCredential($TWILIO_API_SID, $GEN_TOKEN)

    ECHO "[DONE] -> Notifying of finished build, response from Twilio API is:"
    # Make API request, selecting JSON properties from response
    Invoke-WebRequest $WR_URL -Method Post -Credential $WR_CRED -Body $WR_PARAMS -UseBasicParsing |
    ConvertFrom-Json

} else {
    ECHO "[DONE] -> Twilio is missing data parameters!"
}
