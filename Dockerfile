FROM node:22-alpine3.23

WORKDIR /app

RUN apk update && apk upgrade --no-cache

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup && chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000

CMD ["node", "src/app.js"]