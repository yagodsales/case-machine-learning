# Case Seleção

## Software Engineer Python - AWS

### Tarefas

1. Criar um repositório no Github que deve conter todos com os códigos do case;
2. Criar o código que sobe uma API usando IaC (com Terraform, por exemplo), preferencialmente usando o serviço API Gateway da Cloud AWS:
   - O contrato deve ser especificado usando o OpenAPI 3.0 (Swagger)
   - Deve expor um endpoint com um recurso */sobreviventes* que recebe um JSON com um array de características necessárias para escorar o modelo de Machine Learning treinado em cima do Dataset do Titanic. O modelo é disponibilizado neste repositório na seguinte *path*: */modelo/model.pkl*;
   - O método POST deve receber um JSON no body com um array de características e retornar um JSON com a probabilidade de sobrevivência do passageiro, junto com o ID do passageiro;
     - O processamento - escoragem - deve ser feita numa função Lambda **com código escrito em Python**, e caso seja escolhido outro serviço AWS, justificar a escolha;
     - Além disso, a probabilidade de sobrevivência pode ser armazenada em um banco de dados de baixa latência e serverless - DynamoDB;
     - O Banco de Dados e a função Lambda devem ser criados usando IaC com Terraform, por exemplo;
     - **Não provisionar o banco DynamoDB, dado o baixo volume de requisições que serão feitas;**
   - O método GET /sobreviventes deve retornar um JSON com a lista de passageiros que já foram avaliados (fica a critério do candidato implementar paginação ou não);
   - O método GET /sobreviventes/{id} deve retornar um JSON com a probabilidade de sobrevivência do passageiro com o ID informado;
   - O método DELETE deve deletar o passageiro com o ID informado;
3. Disponibilizar os arquivos de IaC (Terraform) no repositório, assim como o contrato OpenAPI e o código da função Lambda;
4. Você possui o prazo de 7 dias corridos para entrega do case, uma vez recebido o link para este repositório;