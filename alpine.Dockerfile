ARG UV_VERSION=0.4.17
ARG PYTHON_VERSION=3.12
ARG BASE_DISTRO=alpine

FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-${BASE_DISTRO} AS build

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_CACHE_DIR=/tmp/uv-cache \
    UV_PYTHON_DOWNLOADS=never

WORKDIR /usr/src/app

RUN --mount=type=cache,target=${UV_CACHE_DIR} \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

FROM python:${PYTHON_VERSION}-${BASE_DISTRO} AS runtime

WORKDIR /usr/src/app
ENV PATH="/usr/src/app/.venv/bin:${PATH}"

COPY --from=build /usr/src/app/.venv /usr/src/app/.venv
RUN adduser -S -D -h /nonexistent app
USER app
COPY hello_world ./hello_world
ENTRYPOINT ["python", "hello_world/main.py"]