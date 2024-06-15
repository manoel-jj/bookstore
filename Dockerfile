# Use uma imagem base oficial do Python
FROM python:3.8.1-slim as python-base

# Defina variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.5.1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Adicione Poetry e o virtualenv ao PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instale dependências do sistema
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    build-essential \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Instale o Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Defina o diretório de trabalho para a instalação das dependências do projeto
WORKDIR $PYSETUP_PATH

# Copie os arquivos de configuração do Poetry
COPY poetry.lock pyproject.toml ./

# Instale apenas as dependências principais (sem dev)
RUN poetry install --no-dev

# Defina o diretório de trabalho para a aplicação
WORKDIR /app

# Copie o restante dos arquivos do projeto
COPY . /app/

# Exponha a porta 8000
EXPOSE 8000

# Defina o comando padrão para executar o servidor Django
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
