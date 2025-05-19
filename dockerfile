
## Baixa e executa a imagem do node na versão Apline (versão simplificada)

FROM node:alpine

## Define o local onde o app ira ficar no disco do container
## Fodase o caminho, o dev escolhe

WORKDIR /usr/app

## Copia tudo que começa com package e termina com .json para dentro de /usr/app/

COPY package*.json ./

## Executa o npm i, e baixa todas as dependências na node_modules

RUN npm i

## Copia tudo que está no diretório onde o arquivo dockerfile está
## Será copiado dentro da pasta /usr/app/
## Vamos ignorar a node_modules (.dockerignore)

COPY . .

## Container ficará ouvindo os acessos na porta 5000

EXPOSE 5000

## Executa o comando para iniciar o script que está no package.json

CMD npm start
