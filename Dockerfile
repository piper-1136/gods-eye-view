FROM node:24-slim AS build

ARG GOOGLE_MAPS_API_KEY=""
ARG CESIUM_ION_TOKEN=""

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY . .

RUN GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY" \
    CESIUM_ION_TOKEN="$CESIUM_ION_TOKEN" \
    npm run build

FROM node:24-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production

COPY --from=build --chown=node:node /app /app

RUN mkdir -p /app/.gev-cache && chown -R node:node /app/.gev-cache

USER node

EXPOSE 4173

CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4173"]