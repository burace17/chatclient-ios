async function getStoredServers() {
    const response = await window.webkit.messageHandlers.credentialManager.postMessage("getStoredServers");
    alert("getStoredServeres response: " + response);
    return [];
}

async function getStoredPasswords(address, username) {

}

async function storeServerInfo(address, username, password) {

}

async function removeServerInfo(address, username) {

}

window.credentialManager = {};
window.credentialManager.getStoredServers = getStoredServers;
window.credentialManager.getStoredPasswords = getStoredServers;
window.credentialManager.storeServerInfo = getStoredServers;
window.credentialManager.removeServerInfo = getStoredServers;