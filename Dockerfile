FROM alpine:latest

# Install prerequisites (npm & jq for json reading)
RUN apk add --update --no-cache npm jq bash
RUN npm install -g @bitwarden/cli

# Copy over custom scripts for crontab & export
COPY bitwardenexport.sh entry.sh /
RUN chmod +x /bitwardenexport.sh /entry.sh

# Create appdata folder for backup & export
RUN mkdir -p /appdata
VOLUME ["/appdata"]

# Container start
ENTRYPOINT [ "/entry.sh" ]
