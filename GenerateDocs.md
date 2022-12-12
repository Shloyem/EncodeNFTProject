Docs were generated using hardhat's plugin called: hardhat-docgen
This is a foundry project, but the tools for hardhat are better at the moment, so to not waste time it was copied to a hardhat project.

### steps in hardhat: 
1. npm install --save-dev hardhat-docgen

2. added to hardhat config:
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: true,
  }

3. On the next compilation it appears in docs folder