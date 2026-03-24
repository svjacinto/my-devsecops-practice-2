FROM node:22-alpine3.23

WORKDIR /app

ENV NODE_ENV=production

RUN apk update && apk upgrade --no-cache

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup && chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000

CMD ["node", "src/app.js"]