FROM ekidd/rust-musl-builder:stable as builder

RUN USER=root cargo new --bin chiselstore
WORKDIR ./chiselstore
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release
RUN rm src/*.rs

ADD . ./

RUN rm ./target/x86_64-unknown-linux-musl/release/deps/chiselstore*
RUN cargo build --release


FROM alpine:latest

ARG APP=/usr/src/app

EXPOSE 50000
EXPOSE 50001

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN addgroup -S $APP_USER \
    && adduser -S -g $APP_USER $APP_USER

COPY --from=builder /home/rust/src/chiselstore/target/x86_64-unknown-linux-musl/release/chiselstore ${APP}/chiselstore

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./chiselstore"]
