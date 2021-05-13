FROM ortussolutions/commandbox:alpine

ENV PORT 80
COPY . /app
COPY flagService.cfc /app/tests/

RUN box server start && box testbox run
