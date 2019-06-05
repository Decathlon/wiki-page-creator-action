FROM alpine/git:latest

LABEL "maintainer"="Decathlon <developers@decathlon.com>"
LABEL "com.github.actions.name"="wiki-page-creator-action"
LABEL "com.github.actions.description"="Action to create a GitHub wiki page based on provided Markdown file"
LABEL "com.github.actions.icon"="book-open"
LABEL "com.github.actions.color"="black"

RUN apk add --no-cache bash findutils
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
