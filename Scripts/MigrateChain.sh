
echo "[INFO] -> Migrating contracts onto new chain..."
# Use Web3 to migrate
node ${shScriptRoot}/Scripts/ChainJS/migrate.js $CONTRACTS

# MUST FIX WEB3
# /node_modules/web3/node_modules/web3-providers/dist/web3-providers.cjs.js
# SEE CHANGES BELOW
# onMessage(response) {
#         let event;
#
#         if (!isObject(response)) {
#             // CHANGE THIS
#             response = JSON.parse(response);
#             // TO THIS
#             response = JSON.parse(response.split("\n")[0]);
#         }
#
#         if (isArray(response)) {
#             event = response[0].id;
#         } else if (typeof response.id === 'undefined') {
#             event = this.getSubscriptionEvent(response.params.subscription);
#             response = response.params;
#         } else {
#             event = response.id;
#         }
#
#         this.emit(this.SOCKET_MESSAGE, response);
#         this.emit(event, response);
# }
