# Build Environment
FROM node:16.14-alpine as react-build

# set our node environment, either development or production
# defaults to production, compose overrides this to development on build and run
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV

# default to port 19006 for node, and 19001 and 19002 (tests) for debug
ARG PORT=19006
ENV PORT $PORT
EXPOSE $PORT 19001 19002

#Set default shell
# SHELL ["/bin/bash", "-c" ]

# install global packages
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH /home/node/.npm-global/bin:$PATH
RUN npm i --unsafe-perm -g npm@latest expo-cli@latest

RUN mkdir /opt/react_native_app && chown node:node /opt/react_native_app
WORKDIR /opt/react_native_app
ENV PATH /opt/react_native_app/.bin:$PATH
USER node
COPY ./react_native_app/package.json ./react_native_app/package-lock.json ./
RUN yarn
RUN npx expo-optimize
RUN ["/bin/bash", "-c" "expo build:web --no-pwa"] 

#Server Environment
FROM nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/configfile.template
COPY --from=react-build /app/web-build /usr/share/nginx/html
ENV PORT 8080
ENV HOST 0.0.0.0
EXPOSE 8080
CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"`