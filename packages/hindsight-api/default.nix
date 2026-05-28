{ lib, python3, fetchFromGitHub, ... }:

python3.pkgs.buildPythonApplication rec {
  pname = "hindsight-api-slim";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "vectorize-io";
    repo = "hindsight";
    rev = "30acca6fd9d882248803d6a48efc965d821e938e";
    hash = "sha256-RTxROxeLkVdmcVQ5UCYSe+SIqKkEeHrYkL9dLnJ3TPY=";
  } + "/hindsight-api-slim";

  pyproject = true;

  nativeBuildInputs = with python3.pkgs; [ hatchling ];

  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    alembic
    anthropic
    asyncpg
    authlib
    boto3
    cohere
    cryptography
    dateparser
    fastapi
    fastmcp
    filelock
    google-auth
    google-genai
    greenlet
    httpx
    langchain-core
    langchain-text-splitters
    langsmith
    litellm
    markitdown
    openai
    opentelemetry-api
    opentelemetry-exporter-otlp-proto-http
    opentelemetry-exporter-prometheus
    opentelemetry-instrumentation-fastapi
    opentelemetry-sdk
    opentelemetry-semantic-conventions
    orjson
    pgvector
    pillow
    protobuf
    psycopg2
    pydantic
    pygments
    pyjwt
    python-dateutil
    python-dotenv
    python-multipart
    rich
    sqlalchemy
    tiktoken
    tornado
    typer
    uvicorn
    uvloop
    wsproto
  ];

  dontCheckRuntimeDeps = true;
  pythonImportsCheck = [ ];

  meta = with lib; {
    description = "Hindsight: Agent Memory That Works Like Human Memory";
    homepage = "https://github.com/vectorize-io/hindsight";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
