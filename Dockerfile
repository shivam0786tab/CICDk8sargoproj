FROM node

WORKDIR /app/

COPY . .

RUN npm cache clean --force && npm install

CMD ["node", "index.js"]


