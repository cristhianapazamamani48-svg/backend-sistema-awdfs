FROM node:22.23.1-slim AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:22.23.1-slim AS runtime

ENV NODE_ENV=production
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app/dist ./dist
COPY --from=build /app/estatico ./estatico
RUN mkdir -p /app/estatico/imagenes \
    && chown -R node:node /app

USER node

EXPOSE 3000

CMD ["node", "dist/main"]
