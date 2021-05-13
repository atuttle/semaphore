FROM ortussolutions/commandbox:alpine

ENV PORT 80
COPY . /app

RUN box server start && box testbox run
