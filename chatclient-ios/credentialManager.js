async function getStoredServers() {
    return await window.webkit.messageHandlers.getStoredServers.postMessage("");
}

async function storeServerInfo(address, username, password) {
    await window.webkit.messageHandlers.storeServerInfo.postMessage([address, username, password]);
}

async function removeServerInfo(address, username) {
    await window.webkit.messageHandlers.removeServerInfo.postMessage([address, username]);
}

window.credentialManager = {};
window.credentialManager.getStoredServers = getStoredServers;
window.credentialManager.storeServerInfo = storeServerInfo;
window.credentialManager.removeServerInfo = removeServerInfo;
