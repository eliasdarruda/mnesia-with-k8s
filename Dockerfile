FROM elixir:1.15.7-alpine as builder

# prepare build dir
WORKDIR /app

RUN apk add --no-cache --update git build-base ca-certificates zstd

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY lib lib

# unsafe https
RUN mix hex.config unsafe_https true

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM alpine:3.17.3

RUN apk add --no-cache --update zstd ncurses-libs libstdc++ libgcc libcrypto1.1

WORKDIR /app

RUN chown nobody /app

# Set runner ENV
ENV MIX_ENV=prod
ENV HOME=/app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/test ./

USER nobody

CMD ["/app/bin/test", "start"]