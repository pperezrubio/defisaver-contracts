usePlugin("@nomiclabs/buidler-waffle");
usePlugin("@nomiclabs/buidler-etherscan");

const dotenv           = require('dotenv').config();
const mnemonic = process.env.ETHEREUM_ACCOUNT_MNEMONIC;

module.exports = {
    networks: {
        buidlerevm: {
        },
        moonnet: {
            url: process.env.MOON_NET_NODE,
            accounts: ['0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d']
        },
        mainnet: {
            url: process.env.ALCHEMY_NODE,
            accounts: [process.env.PRIV_KEY_OWNER]
        },
        kovan: {
            url: process.env.KOVAN_INFURA_ENDPOINT,
            accounts: ['0x222E34D100BB1D8298B6EE15EFD4F656B14D00C22FA030F0F63E0A4AF29367D2']
        },
    },
    solc: {
        version: "0.6.6",
        optimizer: {
            enabled: true,
            runs: 20000
        }
    },
    etherscan: {
        url: "https://api.etherscan.io/api",
        apiKey: process.env.ETHERSCAN_API_KEY
    }
};
