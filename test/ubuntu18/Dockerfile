FROM ubuntu:18.04
MAINTAINER nholuongut <info@nholuongut>

RUN apt-get update
RUN apt-get install -y curl sudo

COPY . /test

CMD ["echo", "This container is used for testing. Consider running one of the test scripts under the /test folder."]
