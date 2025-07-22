###########
# Builder #  (treina e gera model.pkl)
###########
FROM public.ecr.aws/lambda/python:3.10 AS builder

WORKDIR /app

# 1) Dependências de treino
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2) Código e dados de treino
COPY train_and_dump.py .


# 3) Executa treino e serialização
RUN python train_and_dump.py   # gera model.pkl em /app

#################
# Imagem final  #
#################
FROM public.ecr.aws/lambda/python:3.10

WORKDIR /var/task

# 1) Dependências de inferência
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2) Código da Lambda e modelo compatível
COPY titanic_lambda.py .
COPY --from=builder /app/model.pkl .

# 3) Define handler
CMD ["titanic_lambda.lambda_handler"]
