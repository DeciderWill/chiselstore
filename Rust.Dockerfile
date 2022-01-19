FROM ekidd/rust-musl-builder:stable as builder

RUN USER=root cargo new --bin chiselstore
WORKDIR ./chiselstore
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release
RUN rm src/*.rs

COPY . .

RUN rm ./target/x86_64-unknown-linux-musl/release/deps/chiselstore*
RUN cargo build --release
RUN cargo test --verbose --all


FROM alpine:latest

ARG APP=/usr/src/app


EXPOSE 50001
EXPOSE 50002
EXPOSE 50003

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN addgroup -S $APP_USER \
    && adduser -S -g $APP_USER $APP_USER

COPY --from=builder /home/rust/src/chiselstore/target/x86_64-unknown-linux-musl/debug/examples/gouged ${APP}/gouged
COPY --from=builder /home/rust/src/chiselstore/target/x86_64-unknown-linux-musl/debug/examples/gouge ${APP}/gouge

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./gouged"]
