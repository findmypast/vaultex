FROM elixir:1.5

# Install tini entrypoint
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc

RUN chmod +x /tini

# Copy the dependency config over
COPY ./mix.exs /usr/src/app/mix.exs
COPY ./mix.lock /usr/src/app/mix.lock
COPY ./VERSION /usr/src/app/VERSION

WORKDIR /usr/src/app

# Install elixir dependencies
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix do deps.get, deps.compile

# Copy whole app source
COPY . /usr/src/app

RUN mix compile

# Set tini entrypoint
ENTRYPOINT ["/tini", "--"]
