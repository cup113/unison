const { generateOpenApi } = require('@ts-rest/open-api');
const { contract } = require('../dist/types/contract.mjs');
const { writeFileSync } = require('fs');

const openApiDocument = generateOpenApi(contract, {
  info: {
    title: 'Unison API',
    version: '1.0.0',
    description: 'Unison Focus Timer API',
  },
  servers: [
    {
      url: 'https://unison-server.cup11.top',
      description: 'Development server',
    },
  ],
});

writeFileSync('./openapi.json', JSON.stringify(openApiDocument, null, 2));
console.log('OpenAPI specification generated at ./openapi.json');