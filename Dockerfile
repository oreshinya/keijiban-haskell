FROM haskell:8.0.1

MAINTAINER oreshinya

RUN apt-get -qq update && apt-get install -y libmysqlclient-dev pkg-config libpcre3-dev

ARG APP_HOME

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY keijiban.cabal $APP_HOME
COPY stack.yaml $APP_HOME

RUN stack setup

CMD stack build && stack exec keijiban-exe
