FROM public.ecr.aws/lambda/python:3.12

WORKDIR /var/task

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY titanic_lambda.py .
COPY model.pkl .

# Define o entrypoint da Lambda
CMD ["titanic_lambda.lambda_handler"]
